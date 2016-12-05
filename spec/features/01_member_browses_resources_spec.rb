require 'rails_helper'
require 'rake'

NexudusApp::Application.load_tasks
include ActionView::Helpers::DateHelper
RSpec.feature 'Browsing Available Resources:', type: :feature do
  subject { page }

  context 'A Member visiting the "Resources" page' do
    context 'when browsing what resources are available' do
      before(:all) do
        # Default present time to 9/1/2015 14:30 UTC (see fixtures for mock data)
        Timecop.travel(DateTime.strptime('2015-09-01T14:30:00Z').in_time_zone.to_time)
      end
      after(:all) { Timecop.return }

      before { execute_valid_login }

      scenario 'should see ALL offered resources (i.e. prep tables) plotted on a map of the space, with unavailable resources grayed out', js: true do
        visit '/resources'
        should have_css('#map-container div.resource', count: 3, wait: 10)
      end

      scenario 'should see filters for date and time and friendly hint', js: true do
        visit '/resources'
        should have_content('WHEN DO YOU WANT TO COME IN?')
        should have_content('Choose your date and time')
        should have_content('Choose your favorite table')
        should have_content('Cook!')
        expect(find('#filters', visible: false)).to_not have_content(' 3:00 AM')
      end

      scenario 'should be able to filter by date and time they want to come in; defaulted to today, 2 hours from now, minimum of 2 hours' do
        visit '/resources'
        from = (Time.current + 2.hours).beginning_of_hour
        to = (Time.current + 4.hours).beginning_of_hour
        date = Time.current.to_s(:booking_day)
        if (from.hour < 8 && from.hour > 2) || (to.hour < 8 && to.hour > 2)
          date = to.to_s(:booking_day) if to.hour < 8 || to.hour > 2
          from = '8:00 AM'
          to = '12:00 PM'
        else
          from = from.to_s(:booking_time)
          to = to.to_s(:booking_time)
        end
        should have_field('bookingRequestDate', with: date)
        expect(find('#bookingRequestFromTime', visible: false).value).to eq from
        expect(find('#bookingRequestToTime', visible: false).value).to eq to
      end

      scenario 'should see basic description details when hovering on a resource (ex. dimensions, suggestions for how many people can fit - whatever is entered into the backend Nexudus system in the "description" field)', js: true do
        visit '/resources'
        expect(find('div#resource-100')['data-original-title']).to eq 'A. Hedgehog'
        expect(find('div#resource-100')['data-content']).to match(/Work Table/)
      end

      context 'when filtering by date and times' do
        scenario 'should see the resources availability accurately update upon changing the requested date/times and clicking "refresh"', js: true do
          visit '/resources'
          should have_css('#map-container .resource', count: 3, wait: 10)
          # Change to time that conflicts with booking for ID:100
          set_time_range('#filter-time-slider', '13:00 PM', '19:00 PM')
          # wait_for_ajax
          should have_css('#map-container .resource.available', count: 2, wait: 10)
        end

        scenario 'should see a warning if selecting a timespan of more than 12 hours', js: true do
          visit '/resources'
          set_time_range('#filter-time-slider', '8:00 AM', '8:00 PM')
          should have_text('8:00 AM - 8:00 PM')
          set_time_range('#filter-time-slider', '8:00 AM', '8:30 PM')
          should_not have_text('8:00 AM - 8:30 PM')
        end

        scenario 'should see a warning if selecting a date/time that is already passed', js: true do
          visit '/resources'
          fill_in('bookingRequestDate', with: (Time.zone.now - 1.day).to_s(:booking_day))
          page.evaluate_script("$('#filter-time-slider').trigger('slide', true)")
          should have_text('Booking cannot be in the past.')
        end
      end

      context 'with relation to their membership plan' do
        scenario 'should see available remaining hours', js: true do
          visit '/resources'
          page.find(:css, 'li.accounts-nav a').click
          should have_text('1 hour remaining this month')
        end

        scenario 'should see a warning if the requested time exceeds the available hours, with notice about extra billing', js: true do
          visit '/resources'
          fill_in('bookingRequestDate', with: (Time.current + 1.day).to_s(:booking_day))
          set_time_range('#filter-time-slider', '8:00 AM', '2:00 PM')
          page.execute_script('$("div.available:first").trigger("click")') # Since we're using "fake" stubbed resources, they're all going to be displayed on top of one another. Trigger the click directly to avoid click conflicts.
          should have_text('1 hour (you will be invoiced any extras)')
        end
      end
    end
  end

  context '(Real Time) when sending bookings request to Nexudus' do
    before do
      WebMock.reset!
      WebMock.allow_net_connect!
      execute_valid_login
      clear_bookings
    end
    after(:all) { clear_bookings }

    scenario 'should be able to request all bookings (with and without params)', js: true do
      expect(Booking.all).to be_empty
      far_away_time = Time.current.change(hour: 9, minutes: 0, seconds: 0)
      far_away_time += 1.day if far_away_time.sunday?
      # Create 3 new bookings and check count of created bookings
      [far_away_time, far_away_time + 1.day, far_away_time + 1.week].each do |start_time|
        # Somehow default amount of time is not enough for ajax request here, so we'll wait for 10 times longer amount of time
        create_booking(start_time)
      end
      expect(Booking.all.count).to eq 3
      expect(Booking.all(options: {from_time: far_away_time + 1.hour, to_time: far_away_time + 5.hours}).count).to eq 1
    end
  end
end

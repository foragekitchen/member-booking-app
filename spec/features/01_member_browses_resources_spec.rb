require 'rails_helper'
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

      before(:each) { execute_valid_login }

      scenario 'should see ALL offered resources (i.e. prep tables) plotted on a map of the space, with unavailable resources grayed out', js: true do
        visit '/resources'
        should have_css('#map-container div.resource', count: 3, wait: 10)
      end

      scenario 'should see filters for date and time, with "closed" times omitted and friendly hint', js: true do
        visit '/resources'
        should have_content('WHEN DO YOU WANT TO COME IN?')
        should have_content('closed 2AM-8AM')
        expect(find('#filters', visible: false)).to_not have_content(' 3:00 AM')
      end

      scenario 'should be able to filter by date and time they want to come in; defaulted to today, 2 hours from now, minimum of 4 hours' do
        visit '/resources'
        from = (Time.current + 2.hours).beginning_of_hour
        to = (Time.current + 6.hours).beginning_of_hour
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
        expect(find('#bookingRequestFromTime').value).to eq from
        expect(find('#bookingRequestToTime').value).to eq to
      end

      scenario 'should see basic description details when hovering on a resource (ex. dimensions, suggestions for how many people can fit - whatever is entered into the backend Nexudus system in the "description" field)', js: true do
        visit '/resources'
        expect(find('div#resource-100')['data-original-title']).to eq 'A. Hedgehog Prep Table'
        expect(find('div#resource-100')['data-content']).to match(/Work Table/)
      end

      context 'when filtering by date and times' do
        scenario 'should see the resources availability accurately update upon changing the requested date/times and clicking "refresh"', js: true do
          visit '/resources'
          should have_css('#map-container .resource', count: 3, wait: 10)
          # Change to time that conflicts with booking for ID:100
          set_time_range('#filter-time-slider', '13:00 PM', '19:00 PM')
          wait_for_ajax
          should have_css('#map-container .resource.available', count: 2, wait: 10)
        end

        scenario 'should see a warning if selecting a timespan of more than 12 hours', js: true do
          visit '/resources'
          set_time_range('#filter-time-slider', '8:00 AM', '9:00 PM')
          should have_text('Booking cannot be more than 12 hours.')
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

    context 'when selecting a resource, date, and times for booking' do
      before(:each) { execute_valid_login }

      scenario 'should be able to book up to 12 hours, but no more than 12 hours', js: true do
        visit '/resources'
        fill_in('bookingRequestDate', with: (Time.zone.now + 1.day).to_s(:booking_day))
        set_time_range('#filter-time-slider', '10:00 AM', '10:00 PM')
        should_not have_content('Booking cannot be more than 12 hours.')
        set_time_range('#filter-time-slider', '10:00 AM', '10:30 PM')
        should have_content('Booking cannot be more than 12 hours.')
        should have_selector('#disable-map', visible: true)
      end

      pending 'should see a warning if booking more than a month in advance'
      pending 'should see when it is next available if it is not currently available'
      pending 'should see who booked it if it is currently unavailable'
    end
  end
end

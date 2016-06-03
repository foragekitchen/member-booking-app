require 'rails_helper'
require 'rake'
NexudusApp::Application.load_tasks
include ActionView::Helpers::DateHelper
RSpec.feature 'My Bookings:', type: :feature do
  subject { page }

  let(:from_time) { Time.zone.parse('2015-09-01T16:00:00Z').to_s(:booking_time).strip }
  let(:to_time) { Time.zone.parse('2015-09-01T20:00:00Z').to_s(:booking_time).strip }

  def find_booking_on_page(resource_name)
    first('td', text: resource_name)
  end

  def expand_edit_form_for_booking(booking_element, time_interval)
    booking_element.find(:xpath, '..').first('.btn-edit').click
    within('.edit-booking', visible: true) do
      expect(find('.time-slider-range-holder span', text: time_interval, wait: 10)).not_to be_nil
    end
  end

  context 'when viewing existing bookings' do
    before(:all) do
      # Default present time to 9/2/2015 12:01AM (see fixtures for mock data)
      Timecop.travel(Time.zone.parse('2015-09-02T08:30:00Z').to_time)
    end
    after(:all) { Timecop.return }
    before(:each) { execute_valid_login }

    pending 'should see a list of booking(s) currently in-progress, including a marker for whether they\'ve checked in yet'

    scenario 'should see a list of upcoming bookings, ordered by soonest at the top' do
      visit '/bookings'
      should have_css('table#upcoming-bookings tbody tr', count: 2 * 2) # account for the hidden edit forms
      expect(first('table tr td:nth-child(2)')).to have_content('In about 8 hours (Sep 2)')
      expect(first('table tr td:nth-child(3)')).to have_content("#{from_time} - #{to_time}")
    end

    scenario 'should see a link to past bookings' do
      visit '/bookings'
      should have_css('#past-bookings')
    end

    scenario 'should be given the option to edit a booking' do
      visit '/bookings'
      should have_selector(:link_or_button, 'Edit')
      should have_css('.edit-booking', visible: true)
    end
  end

  context 'when attempting to edit an existing booking' do
    before(:all) do
      # Default present time to 9/2/2015 12:01AM (see fixtures for mock data)
      Timecop.travel(Time.zone.parse('2015-09-02T08:30:00Z').to_time)
    end
    after(:all) { Timecop.return }
    before(:each) { execute_valid_login }

    describe do
      before do
        visit '/bookings'
        node = find_booking_on_page('A. Hedgehog Prep Table')
        @booking_id = node.find(:xpath, '..')['id']
        expand_edit_form_for_booking(node, "#{from_time} - #{to_time}")
      end
      scenario 'should see a warning if editing date/time within 24 hours of the original start-time', js: true do
        set_time_range("#filter-time-slider-#{@booking_id}", '11:00 AM', '15:00 PM')
        should have_css('div', text: 'Locked. This booking starts in less than 24 hours.', visible: true, wait: 10)
      end

      scenario 'should not be able to reduce hours within 24 hours of the original start-time', js: true do
        set_time_range("#filter-time-slider-#{@booking_id}", '8:00 PM', '12:00 AM')
        within('.edit-booking', visible: true) do
          expect(find('.time-slider-range-holder span', text: '9:00 AM - 1:00 PM', wait: 10)).not_to be_nil
        end
      end

      scenario 'should see a warning if the requested time exceeds the available hours in their plan', js: true do
        set_time_range("#filter-time-slider-#{@booking_id}", '9:00 AM', '4:00 PM')
        should have_text('exceeds the hours remaining in your plan')
        should have_text('you will be invoiced')
      end
    end
  end

  context '(Real time) when canceling an existing booking' do
    before(:each) do
      # Let's test against the live server for this one
      WebMock.reset!
      WebMock.allow_net_connect!
      execute_valid_login
    end

    scenario 'should be able to successfully complete a valid cancellation', js: true do
      create_booking(available_start_time(Time.current + 2.days))

      visit '/bookings'
      count = all('#upcoming-bookings tbody tr', visible: true).count
      accept_confirm { first(:link, 'Remove').click }
      should have_css('#upcoming-bookings tbody tr', count: count - 1, wait: 10)
    end
  end

  context '(Real time) when saving changes to an existing booking' do
    before(:each) do
      # Let's test against the live server for this one
      WebMock.reset!
      WebMock.allow_net_connect!
      execute_valid_login
    end
    after(:each) { Rake::Task['data:bookings:delete_upcoming'].invoke }

    scenario 'should see a warning if changing the booking-time conflicts with another booking', js: true do
      date = available_start_time(Time.current + 4.days)
      sooner_booking = create_booking(date)
      create_booking(date + 4.hours)
      visit '/bookings'
      node = find_booking_on_page(sooner_booking[:resource_name])
      expand_edit_form_for_booking(node, "#{sooner_booking[:start_time]} - #{sooner_booking[:end_time]}")
      extended_to_time = (date + 5.hours).beginning_of_hour.to_s(:booking_time)
      booking_id = node.find(:xpath, '..')['id']
      within('.edit-booking', visible: true) do
        set_time_range("#filter-time-slider-#{booking_id}", sooner_booking[:start_time], extended_to_time)
        click_button('Update')
      end

      should have_text('Oh no!')
      should have_text('An error occurred while updating your booking')
    end

    scenario 'should be able to successfully complete an update', js: true do
      start_time = available_start_time(Time.current + 3.days)
      booking = create_booking(start_time)

      visit '/bookings'
      node = find_booking_on_page(booking[:resource_name])
      expand_edit_form_for_booking(node, booking[:end_time])
      booking_id = node.find(:xpath, '..')['id']
      within('.edit-booking', visible: true) do
        set_time_range("#filter-time-slider-#{booking_id}", booking[:start_time], (start_time + 6.hours).to_s(:booking_time))
        click_button('Update')
      end

      should have_text('Success!')
      should have_text('was successfully updated')
    end
  end
end

require 'rails_helper'
require 'rake'
NexudusApp::Application.load_tasks
RSpec.feature 'Booking Kitchen Time:', type: :feature do
  subject { page }

  context '(Real time) when booking a table for a chosen date/time' do
    before do
      # Let's test against the live server for this one
      WebMock.reset!
      WebMock.allow_net_connect!
      execute_valid_login
      clear_bookings
    end
    after(:all) { clear_bookings }

    scenario 'should be able to change date, and/or start and end time(s), and see if it\'s still available', js: true do
      date = available_start_time(Time.current + 1.day)
      visit '/resources'
      set_time_range('#filter-time-slider', date.to_s(:booking_time), (date + 4.hours).to_s(:booking_time))
      wait_for_ajax
      first('.resource.available', wait: 10).click
      should have_link('Change')
    end

    scenario 'should be able to save a valid booking and see it appear on My Reservations', js: true do
      visit '/bookings'
      should_not have_css('table#upcoming-bookings')

      create_booking(available_start_time(Time.current + 2.days))

      visit '/bookings'
      should have_css('table#upcoming-bookings tbody tr', count: 1, wait: 10)
    end
  end
end

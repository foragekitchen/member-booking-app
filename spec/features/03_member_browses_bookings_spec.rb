require 'rails_helper'
require 'rake'
NexudusApp::Application.load_tasks
include ActionView::Helpers::DateHelper

RSpec.feature "My Bookings:", type: :feature do
  let(:from_time) { DateTime.strptime("2015-09-01T16:00:00Z").in_time_zone.to_time.strftime('%l:%M %p').strip }
  let(:to_time) { DateTime.strptime("2015-09-01T20:00:00Z").in_time_zone.to_time.strftime('%l:%M %p').strip }

  def find_booking_on_page(resource_name)
    page.first("td", text: resource_name)
  end

  def expand_edit_form_for_booking(booking_element, end_time_for_validation)
    booking_element.find(:xpath, '../..').first('.btn-edit').click
    page.find("#bookingTo_chosen span", visible: false, text: end_time_for_validation.strip, wait: 10) # wait till the form's properly loaded/updated before doing anything else, by checking for its availability
  end

  context "when viewing existing bookings" do

    before(:all) do
      # Default present time to 9/2/2015 12:01AM (see fixtures for mock data)
      Timecop.travel(DateTime.strptime('2015-09-02T08:30:00Z').in_time_zone.to_time)
    end

    before(:each) do
      execute_valid_login
    end

    after(:all) do
      Timecop.return
    end

    pending "should see a list of booking(s) currently in-progress, including a marker for whether they've checked in yet"

    scenario "should see a list of upcoming bookings, ordered by soonest at the top" do
      visit "/bookings"
      expect(page).to have_css("table#upcoming-bookings tbody tr", count: 2 * 2) # account for the hidden edit forms
      expect(page.first("table tr td:nth-child(2)")).to have_content("In about 8 hours (Sep 2)")
      expect(page.first("table tr td:nth-child(3)")).to have_content("#{from_time} - #{to_time}")
    end

    scenario "should see a link to past bookings" do
      visit "/bookings"
      expect(page).to have_css("#past-bookings.collapse")
    end

    scenario "should be given the option to edit a booking" do
      visit "/bookings"
      expect(page).to have_selector(:link_or_button, 'Edit')
      expect(page).to have_css('.edit-booking', visible: true)
    end

  end

  context "when attempting to edit an existing booking" do

    before(:all) do
      # Default present time to 9/2/2015 12:01AM (see fixtures for mock data)
      Timecop.travel(DateTime.strptime('2015-09-02T08:30:00Z').in_time_zone.to_time)
    end

    before(:each) do
      execute_valid_login
    end

    after(:all) do
      Timecop.return
    end

    scenario "should see a warning if editing date/time within 24 hours of the original start-time", js: true do
      visit "/bookings"
      expand_edit_form_for_booking(find_booking_on_page("A. Hedgehog Prep Table"), to_time)
      page.find("a", text: from_time).click
      expect(page).to have_css("div", text: "Locked. This booking starts in less than 24 hours.", visible: true, wait: 10)
    end

    scenario "should not be able to reduce hours within 24 hours of the original start-time", js: true do
      visit "/bookings"
      expand_edit_form_for_booking(find_booking_on_page("A. Hedgehog Prep Table"), to_time)
      expect(page).to have_css("#bookingTo option[disabled]", text: "12:00 PM", visible: false, wait: 10)
    end

    scenario "should see a warning if the requested time exceeds the available hours in their plan", js: true do
      visit "/bookings"
      expand_edit_form_for_booking(find_booking_on_page("A. Hedgehog Prep Table"), to_time)
      within('.edit-booking:first') { select_from_chosen(" 2:00 AM", from: "bookingTo") }
      expect(page).to have_text("exceeds the hours remaining in your plan")
      expect(page).to have_text("you will be invoiced")
    end

  end

  context "(Real time) when canceling an existing booking" do
    before(:each) do
      #Let's test against the live server for this one
      WebMock.reset!
      WebMock.allow_net_connect!
      execute_valid_login
    end

    scenario "should be able to successfully complete a valid cancellation", js: true do
      create_booking(Date.today + 2.days + hours_offset)

      visit "/bookings"
      count = page.all('#upcoming-bookings tbody tr', visible: true).count
      accept_confirm { first(:link, "Remove").click }
      expect(page).to have_css("tbody tr", count: count - 1, wait: 10)
    end
  end

  context "(Real time) when saving changes to an existing booking" do
    before(:each) do
      #Let's test against the live server for this one
      WebMock.reset!
      WebMock.allow_net_connect!
      execute_valid_login
    end

    after(:each) do
      Rake::Task['data:bookings:deleteUpcoming'].invoke
    end

    scenario "should see a warning if changing the booking-time conflicts with another booking", js: true do
      date = Date.today + 4.days + hours_offset
      sooner_booking = create_booking(date)
      create_booking(date + 4.hours)

      visit "/bookings"
      this_booking = find_booking_on_page(sooner_booking[:resource_name])
      expand_edit_form_for_booking(this_booking, sooner_booking[:end_time])
      extended_to_time = (date + 5.hours).beginning_of_hour.to_s(:booking_time)
      select_from_chosen(extended_to_time, from: "bookingTo", wait: 10)
      click_button("Update")

      expect(page).to have_text("Oh no!")
      expect(page).to have_text("already booked")
    end

    scenario "should be able to successfully complete an update", js: true do
      booking = create_booking(Date.today + 3.days + hours_offset)

      visit "/bookings"
      this_booking = find_booking_on_page(booking[:resource_name])
      expand_edit_form_for_booking(this_booking, booking[:end_time])
      # Update some values
      if Booking::TIMESLOTS[Booking::TIMESLOTS.index(booking[:end_time]).next].nil?
        select_from_chosen(Booking::TIMESLOTS[Booking::TIMESLOTS.index(booking[:end_time]) - 9], from: "bookingFrom", wait: 10)
      else
        select_from_chosen(Booking::TIMESLOTS[Booking::TIMESLOTS.index(booking[:end_time]).next], from: "bookingTo", wait: 10)
      end
      click_button("Update")

      expect(page).to have_text("Success!")
      expect(page).to have_text("was successfully updated")
    end

  end

end

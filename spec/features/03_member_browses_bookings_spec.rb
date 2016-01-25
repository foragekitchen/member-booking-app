require 'rails_helper'
require 'rake'
NexudusApp::Application.load_tasks
include ActionView::Helpers::DateHelper

RSpec.feature "My Bookings:", type: :feature do

  def createBooking(startTime = nil)
    # Create a real booking - useful for doing before testing anything else
    visit "/resources"
    if startTime.present? && startTime.is_a?(Time)
      from = startTime.beginning_of_hour
      to = (from + 4.hours).to_s(:booking_time).strip
      from = from.to_s(:booking_time).strip
      select_from_chosen(from, from: "bookingRequestFromTime")
      select_from_chosen(to, from: "bookingRequestToTime")
      click_button("Refresh")
    end
    page.first("div.available div.button", :wait => 10).click
    # Remember some stuff so we can find this booking later
    booking = {
      :resource_name => page.find(".modal-title span").text,
      :end_time => page.find(".modal-body h5 span").text.split("-").last
    }
    click_button("Save your booking")
    return booking
  end

  def findBookingOnPage(resource_name)
    return page.first("td", :text => resource_name)
  end

  def expandEditFormForBooking(booking_element, end_time_for_validation)
    booking_element.find(:xpath,'../..').first('.btn-edit').click 
    page.find("#bookingTo_chosen span", visible: false, :text => end_time_for_validation.strip, :wait => 10) # wait till the form's properly loaded/updated before doing anything else, by checking for its availability
  end

  context "when viewing existing bookings" do

    before(:all) do
      # Default present time to 9/2/2015 12:01AM (see fixtures for mock data)
      Timecop.travel(Time.local(2015,9,2,00,01,0))
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
      expect(page).to have_css("table#upcoming-bookings tbody tr", :count => 2+1) # account for the hidden EditForm row
      expect(page.first("table tr td:nth-child(2)")).to have_content("In about 9 hours (Sep 2)")
      expect(page.first("table tr td:nth-child(3)")).to have_content("9:00 AM - 1:00 PM")
    end

    scenario "should see a link to past bookings" do
      visit "/bookings"
      expect(page).to have_css("#past-bookings.collapse")
    end

    scenario "should be given the option to edit a booking" do
      visit "/bookings"
      expect(page).to have_selector(:link_or_button, 'Edit')
      expect(page).to have_css("#editBookingForm")
    end

    pending "should see available remaining hours in plan"
    pending "should see available remaining credit, if purchased extra hours"

  end

  context "when canceling an existing booking" do

    before(:each) do
      #Let's test against the live server for this one
      WebMock.reset!
      WebMock.allow_net_connect!
      execute_valid_login
    end

    scenario "should be able to successfully complete a cancellation", js:true do
      booking = createBooking()

      visit "/bookings"
      count = page.all('tbody tr').count
      accept_confirm { first(:link, "Remove").click }
      expect(page).to have_css("tbody tr", :count => count-1, :wait => 10)
    end

  end
  
  context "when editing an existing booking" do

    before(:each) do
      #Let's test against the live server for this one
      WebMock.reset!
      WebMock.allow_net_connect!
      execute_valid_login
    end

    after(:each) do
      Rake::Task['data:bookings:deleteUpcoming'].invoke
    end

    pending "should see a warning if editing date/time within 24 hours of the original start-time"
    pending "should see a warning if reducing hours within 24 hours of the original start-time"

    scenario "should see a warning if changing the booking-time conflicts with another booking", js:true do
      laterBooking = createBooking(Time.now + 6.hours)
      soonerBooking = createBooking()

      visit "/bookings"
      thisBooking = findBookingOnPage(soonerBooking[:resource_name])
      expandEditFormForBooking(thisBooking,soonerBooking[:end_time])
      extendedToTime = (Time.now + 7.hours).beginning_of_hour.to_s(:booking_time)
      select_from_chosen(extendedToTime, :from => "bookingTo", :wait => 10)
      click_button("Update")
      expect(page).to have_text("Oh no!")
      expect(page).to have_text("already booked")
    end

    pending "should see a warning if the requested time exceeds the available hours in their plan, with one-click option to purchase more"

    scenario "should be able to successfully complete an update", js:true do
      booking = createBooking()

      visit "/bookings"
      thisBooking = findBookingOnPage(booking[:resource_name])
      expandEditFormForBooking(thisBooking,booking[:end_time])
      # Update some values
      select_from_chosen(" 6:00 PM", :from => "bookingFrom", :wait => 10)
      select_from_chosen("11:30 PM", :from => "bookingTo", :wait => 10)
      click_button("Update")
      expect(page).to have_text("6:00 PM - 11:30 PM")
    end

  end

end

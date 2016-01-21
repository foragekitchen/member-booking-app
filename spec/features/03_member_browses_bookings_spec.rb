require 'rails_helper'

RSpec.feature "My Bookings:", type: :feature do

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

    pending "should be given the option to edit a booking"
    pending "should see available remaining hours in plan"
    pending "should see available remaining credit, if purchased extra hours"

  end

  context "when editing an existing booking" do

    pending "should see a warning if editing date/time within 24 hours of the original start-time"
    pending "should see a warning if reducing hours within 24 hours of the original start-time"
    pending "should see a warning if changing the booking-time conflicts with another booking"
    pending "should see a warning if the requested time exceeds the available hours in their plan, with one-click option to purchase more"

  end
  
  context "when canceling an existing booking" do

    before(:each) do
      #Let's test against the live server for this one
      WebMock.reset!
      WebMock.allow_net_connect!
      execute_valid_login
    end

    scenario "should be able to successfully complete a cancellation", js:true do
      #Create a real booking first
      visit "/resources"
      page.first("div.available div.button", :wait => 10).click
      click_button("Save your booking")

      visit "/bookings"
      count = page.all('tbody tr').count
      accept_confirm { first(:link, "Remove").click }
      expect(page).to have_css("tbody tr", :count => count-1, :wait => 10)
    end

  end


end

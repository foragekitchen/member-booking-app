require 'rails_helper'

RSpec.feature "Booking Kitchen Time:", type: :feature do

  context "when booking a table for a chosen date/time" do

    before(:each) do
      #Let's test against the live server for this one
      WebMock.reset!
      WebMock.allow_net_connect!
      execute_valid_login
    end

    after(:all) do
      # TODO - Remove all test data from this user
    end

    scenario "should be able to save a valid booking and see it appear on My Reservations", js:true do
      visit "/bookings"
      bookings = Array.new
      bookings = page.find('table#upcoming-bookings tbody').all('tr')
      count = bookings.size

      visit "/resources"
      page.first("div.available div.button", :wait => 10).click
      expect(page).to have_selector("button", :text => "Save your booking")
      click_button("Save your booking")
      
      visit "/bookings"
      expect(page).to have_css("table#upcoming-bookings tbody tr", :count => count+1, :wait => 10)
    end

  end

end

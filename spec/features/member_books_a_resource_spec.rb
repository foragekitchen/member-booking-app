require 'rails_helper'

RSpec.feature "Book Kitchen Time:", type: :feature do

  context "Member visiting Resources page" do

    context "when browsing what resources are available" do
      scenario "should see all offered resources, e.g. prep tables, plotted on a map of the space", js: true do
        visit "/resources"
        expect(page).to have_css("#map-container div.resource", wait: 10)
      end
    
      pending "should default to today, 2 hours from now"
      pending "should be able to filter by date they want to come in"
      pending "should be able to filter by time they want to come in"
      pending "should see resources marked for booking, only if they are available at the date/time they want"
      pending "should see unavailable (but offered) resources grayed out"
      pending "should see basic details when clicking on a resource (e.g. dimensions, suggestions for how many people can fit)"

      context "with relation to their membership plan" do
        pending "should see available remaining hours"
        pending "should see a warning if the requested time exceeds the available hours, with one-click option to purchase more"
      end

      pending "should be able to select a resource, date, and time for booking"
    end
    
    context "when selecting a resource to book" do
      
      pending "should be required to book a minimum of 4 hours"
      pending "should be able to extend the booking time up to 12 hours"
      pending "should be able to change the start-time, and see if it's still available"
      pending "should be able to change the date, and see if it's still available"
      pending "should see a warning if the requested booking time conflicts with someone else"
      pending "should see a warning if booking more than a month in advance"
      pending "should see when it is next available if it is not currently available"
      pending "should see who booked it if it is currently unavailable"

    end
    
    context "when finalizing a booking" do

      pending "should see a friendly confirmation message"
      pending "should be given the option to duplicate and/or make a recurring booking (TBD)"
      pending "should see the reservation appear in the Bookings list"

    end

  end

end

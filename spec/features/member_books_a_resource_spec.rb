require 'rails_helper'

RSpec.feature "Book Kitchen Time:", type: :feature do

  context "Member visiting Resources page" do

    context "when browsing what resources are available" do
      scenario "should see resources, e.g. prep tables, plotted on a map of the space", js: true do
        visit "/resources"
        expect(page).to have_css("#map-container div.resource", wait: 10)
      end
    
      pending "should default to today, 2 hours from now"
      pending "should be able to filter by date they want to come in"
      pending "should be able to filter by time they want to come in"
      pending "should only see resources that are available at the date/time they want"
      pending "should see basic details when clicking on a resource (e.g. dimensions, suggestions for how many people can fit)"
      pending "should see a warning if the requested time exceeds the available hours in their plan"
      pending "should see available remaining hours in plan"
      pending "should be able to select a resource, date, and time for booking"
    end
    
    context "when selecting a resource to book" do
      
      pending "should be required to book at least 4 hours"
      pending "should be able to extend the booking time up to 10 hours"
      pending "should be able to change the start-time, and see if it's still available"
      pending "should be able to change the date, and see if it's still available"
      pending "should see a warning if the requested booking time conflicts with someone else"
      pending "should see suggestions for other table(s) that available"

    end
    
    context "when finalizing a booking" do

      pending "should see a friendly confirmation message"
      pending "should be given the option to duplicate the booking, defaulted to same time the next day (with a warning if not available)"
      pending "should see the reservation appear in the Bookings list"

    end

  end

end

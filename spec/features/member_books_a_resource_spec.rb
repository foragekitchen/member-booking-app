require 'rails_helper'

RSpec.feature "Booking Kitchen Time:", type: :feature do

  context "A Member visiting the 'Resources' page" do

    context "when browsing what resources are available" do

      before(:all) do
        # Default present time to 9/1/2015 6:18AM (see fixtures for mock data)
        Timecop.travel(Time.local(2015,9,1,6,18,0))
      end
      
      after(:all) do
        Timecop.return
      end

      scenario "should see ALL offered resources (i.e. prep tables) plotted on a map of the space, with unavailable resources grayed out", js: true do
        visit "/resources"
        expect(page).to have_css("#map-container div.resource", :count => 3, :wait => 10)
      end
    
      pending "should see filters for date and time, with 'closed' times disabled and friendly hint (ex: 'sorry! our space is closed 3am-6am for cleaning')"

      scenario "should be able to filter by date and time they want to come in; defaulted to today, 2 hours from now, minimum of 4 hours" do
        visit "/resources"
        expect(page).to have_field("bookingRequestDate", :with => Date.today.strftime("%m/%d/%Y"))
        expect(page).to have_select("bookingRequestFromTime", :selected => (Time.now + 2.hours).beginning_of_hour.strftime("%l:%M %p").strip)
        expect(page).to have_select("bookingRequestToTime", :selected => (Time.now + 6.hours).beginning_of_hour.strftime("%l:%M %p").strip)
      end

      scenario "should see basic description details when hovering on a resource (ex. dimensions, suggestions for how many people can fit - whatever is entered into the backend Nexudus system in the 'description' field)", js: true do
        visit "/resources"
        expect(find("div#resource-100")['data-original-title']).to eq "A. Hedgehog Prep Table"
        expect(find("div#resource-100")['data-content']).to match /Work Table/
      end

      context "when filtering by date and times" do

        scenario "should see the resources' availability accurately update upon changing the requested date/times and clicking 'refresh'", js: true do
          visit "/resources"
          # Defaults to 8 AM, 2 out of 3 offered
          expect(page).to have_css("#map-container div.resource.available", :count => 2, :wait => 10)
          # Change to 2 PM, conflicts with booking
          select_from_chosen("2:00 PM", from: "bookingRequestFromTime")
          select_from_chosen("7:00 PM", from: "bookingRequestToTime")
          click_button("Refresh")
          expect(page).to have_css("#map-container div.resource.available", :count => 1, :wait => 10)
          # Change to 8 PM, should be free again
          select_from_chosen("8:00 PM", from: "bookingRequestFromTime")
          select_from_chosen("11:00 PM", from: "bookingRequestToTime")
          click_button("Refresh")
          expect(page).to have_css("#map-container div.resource.available", :count => 2, :wait => 10)
        end
    
        pending "should see a warning if selecting a timespan of less than 4 hours"
        pending "should see a warning if selecting a timespan of more than 12 hours"
        pending "should see a warning if selecting a date/time that is already passed"

      end


      context "with relation to their membership plan" do
        pending "should see available remaining hours"
        pending "should see a warning if the requested time exceeds the available hours, with one-click option to purchase more"
      end

    end
    
    context "when selecting a resource, date, and times for booking" do
      
      pending "should be required to book a minimum of 4 hours"
      pending "should be able to extend the booking time up to 12 hours"
      pending "should be able to change date, and/or start and end time(s), and see if it's still available"
      pending "should see a warning if the requested booking time conflicts with someone else"
      pending "should see a warning if booking more than a month in advance"
      pending "should see when it is next available if it is not currently available"
      pending "should see who booked it if it is currently unavailable"

    end
    
    context "when finalizing a booking" do

      pending "should be able to save a valid booking, with a friendly confirmation message"
      pending "should be given the option to duplicate and/or make a recurring booking (TBD)"
      pending "should see the reservation appear in the Bookings list"

    end

  end

end

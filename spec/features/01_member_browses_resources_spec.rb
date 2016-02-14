require 'rails_helper'
include ActionView::Helpers::DateHelper

RSpec.feature "Browsing Available Resources:", type: :feature do

  context "A Member visiting the 'Resources' page" do

    context "when browsing what resources are available" do

      before(:all) do
        # Default present time to 9/1/2015 6:18AM (see fixtures for mock data)
        Timecop.travel(Time.local(2015,9,1,6,18,0))
      end
      
      before(:each) do
        execute_valid_login
      end

      after(:all) do
        Timecop.return
      end

      scenario "should see ALL offered resources (i.e. prep tables) plotted on a map of the space, with unavailable resources grayed out", js: true do
        visit "/resources"
        expect(page).to have_css("#map-container div.resource", :count => 3, :wait => 10)
      end
    
      scenario "should see filters for date and time, with 'closed' times omitted and friendly hint (ex: 'sorry! our space is closed 3am-6am for cleaning')", js: true do
        visit "/resources"
        expect(page).to have_content("When do you want to come in?")
        expect(page).to have_content("closed 2AM-8AM")
        page.find("#bookingRequestToTime_chosen").click
        expect(page.find("#filters", :visible => false)).to have_no_content(" 3:00 AM")
      end

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
          # Defaults to 8AM - 12PM, 2 out of 3 offered (100,101)
          expect(page).to have_css("#map-container div.resource.available", :count => 2, :wait => 10)
          # Change to 2 PM, conflicts with 1-7pm booking for ID:100
          select_from_chosen(" 2:00 PM", from: "bookingRequestFromTime")
          select_from_chosen(" 7:00 PM", from: "bookingRequestToTime")
          click_button("Refresh")
          expect(page).to have_css("#map-container div.resource.available", :count => 1, :wait => 10)
          # Change to 7:30 PM, should be free again
          select_from_chosen(" 7:30 PM", from: "bookingRequestFromTime")
          select_from_chosen("11:30 PM", from: "bookingRequestToTime")
          click_button("Refresh")
          expect(page).to have_css("#map-container div.resource.available", :count => 2, :wait => 10)
        end
    
        scenario "should see a warning if selecting a timespan of less than 4 hours", js:true do
          visit "/resources"
          # Defaults to 8AM - 12PM
          select_from_chosen("11:00 AM", from: "bookingRequestToTime")
          expect(page).to have_text("Booking must be at least 4 hours.")
        end

        scenario "should see a warning if selecting a timespan of more than 12 hours", js:true do
          visit "/resources"
          # Defaults to 8AM - 12PM
          select_from_chosen(" 9:00 PM", from: "bookingRequestToTime")
          expect(page).to have_text("Booking cannot be more than 12 hours.")
        end

        scenario "should see a warning if selecting a date/time that is already passed", js:true do
          visit "/resources"
          fill_in('When do you want to come in?', :with => (Time.now - 1.day).to_s(:booking_day))
          page.execute_script("$('#bookingRequestDate').trigger('change');") 
          expect(page).to have_text("Booking cannot be in the past.")
        end

      end


      context "with relation to their membership plan" do
        pending "should see available remaining hours"
        pending "should see a warning if the requested time exceeds the available hours, with one-click option to purchase more"
      end

    end
    
    context "when selecting a resource, date, and times for booking" do
      
      before(:each) do
        execute_valid_login
      end

      scenario "should be required to book a minimum of 4 hours", js:true do
        visit "/resources"
        select_from_chosen(" 3:00 PM", from: "bookingRequestFromTime")
        select_from_chosen(" 5:00 PM", from: "bookingRequestToTime")
        expect(page).to have_content("Booking must be at least 4 hours.")
        expect(page).to have_selector("input[type=submit][value='Refresh']:disabled")
      end

      scenario "should be able to book up to 12 hours, but no more than 12 hours", js:true do
        visit "/resources"
        select_from_chosen(" 8:00 AM", from: "bookingRequestFromTime")
        select_from_chosen(" 8:00 PM", from: "bookingRequestToTime")
        expect(page).to have_no_content("Booking cannot be more than 12 hours.")
        select_from_chosen(" 8:30 PM", from: "bookingRequestToTime")
        expect(page).to have_content("Booking cannot be more than 12 hours.")
        expect(page).to have_selector("input[type=submit][value='Refresh']:disabled")
      end

      pending "should see a warning if booking more than a month in advance"
      pending "should see when it is next available if it is not currently available"
      pending "should see who booked it if it is currently unavailable"

    end
    

  end

end

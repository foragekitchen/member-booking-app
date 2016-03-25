require 'rails_helper'
include ActionView::Helpers::DateHelper

RSpec.feature "Browsing Available Resources:", type: :feature do

  context "A Member visiting the 'Resources' page" do

    context "when browsing what resources are available" do

      before(:all) do
        # Default present time to 9/1/2015 14:30 UTC (see fixtures for mock data)
        Timecop.travel(DateTime.strptime('2015-09-01T14:30:00Z').in_time_zone.to_time)
      end

      before(:each) do
        execute_valid_login
        sleep 1
      end

      after(:all) do
        Timecop.return
      end

      scenario "should see ALL offered resources (i.e. prep tables) plotted on a map of the space, with unavailable resources grayed out", js: true do
        visit "/resources"
        expect(page).to have_css('#map-container div.resource', count: 3, wait: 10)
      end

      scenario "should see filters for date and time, with 'closed' times omitted and friendly hint (ex: 'sorry! our space is closed 3am-6am for cleaning')", js: true do
        visit "/resources"
        expect(page).to have_content("When do you want to come in?")
        expect(page).to have_content("closed 2AM-8AM")
        # page.find("#bookingRequestToTime_chosen").click # Why are we clicking it?
        expect(page.find("#filters", visible: false)).to_not have_content(" 3:00 AM")
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
          # Defaults: 2 out of 3 offered (100, 101)
          expect(page).to have_css("#map-container div.resource.available", :count => 2, :wait => 10)
          # Change to time that conflicts with booking for ID:100
          select_from_chosen(" 8:00 PM", from: "bookingRequestFromTime")
          select_from_chosen("12:00 AM", from: "bookingRequestToTime")
          click_button("Refresh")
          expect(page).to have_css("#map-container div.resource.available", :count => 1, :wait => 10)
        end

        scenario "should see a warning if selecting a timespan of less than 4 hours", js:true do
          visit "/resources"
          select_from_chosen("10:00 PM", from: "bookingRequestFromTime")
          select_from_chosen("11:00 PM", from: "bookingRequestToTime")
          expect(page).to have_text("Booking must be at least 4 hours.")
        end

        scenario "should see a warning if selecting a timespan of more than 12 hours", js:true do
          visit "/resources"
          select_from_chosen("11:00 PM", from: "bookingRequestFromTime")
          select_from_chosen("10:00 PM", from: "bookingRequestToTime")
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
        scenario "should see available remaining hours", js: true do
          visit "/resources"
          page.find(:css, "li.accounts-nav a").click
          expect(page).to have_text("1 hour remaining this month")
        end

        scenario "should see a warning if the requested time exceeds the available hours, with notice about extra billing", js:true do
          visit "/resources"
          select_from_chosen(" 2:00 PM", from: "bookingRequestToTime")
          page.execute_script("$('div.available div.button').first().trigger('click')") # Since we're using "fake" stubbed resources, they're all going to be displayed on top of one another. Trigger the click directly to avoid click conflicts.
          expect(page).to have_text("1 hour (you will be invoiced any extras)")
        end
      end

    end

    context "when selecting a resource, date, and times for booking" do

      before(:each) do
        execute_valid_login
        sleep 1
      end

      scenario "should be required to book a minimum of 4 hours", js:true do
        visit "/resources"
        select_from_chosen("10:00 PM", from: "bookingRequestFromTime")
        select_from_chosen("11:00 PM", from: "bookingRequestToTime")
        expect(page).to have_content("Booking must be at least 4 hours.")
        expect(page).to have_selector("#bookingFilters input[type=submit]:disabled")
      end

      scenario "should be able to book up to 12 hours, but no more than 12 hours", js:true do
        visit "/resources"
        select_from_chosen(" 8:00 AM", from: "bookingRequestFromTime")
        select_from_chosen(" 8:00 PM", from: "bookingRequestToTime")
        expect(page).to_not have_content("Booking cannot be more than 12 hours.")
        select_from_chosen(" 8:30 PM", from: "bookingRequestToTime")
        expect(page).to have_content("Booking cannot be more than 12 hours.")
        expect(page).to have_selector("#bookingFilters input[type=submit]:disabled")
      end

      pending "should see a warning if booking more than a month in advance"
      pending "should see when it is next available if it is not currently available"
      pending "should see who booked it if it is currently unavailable"

    end


  end

end

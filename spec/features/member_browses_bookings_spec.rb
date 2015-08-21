require 'rails_helper'

RSpec.feature "My Bookings:", type: :feature do

  context "when viewing existing bookings" do

    pending "should see a list of booking(s) currently in-progress, including a marker for whether they've checked in yet"
    pending "should see a list of upcoming bookings, ordered by soonest at the top"
    pending "should see a link to past bookings"
    pending "should be given the option to edit a booking"
    pending "should be given the option to cancel a booking"
    pending "should see available remaining hours in plan"
    pending "should see available remaining credit, if purchased extra hours"

  end

  context "when editing an existing booking" do

    pending "should see a warning if editing within 15 minutes of the start-time"
    pending "should see a warning if changing the booking-time conflicts with another booking"
    pending "should see a warning if the requested time exceeds the available hours in their plan, with option to purchase more"

  end
  

end

class BookingsController < ApplicationController

  def create 
    newBooking = {
      "ResourceId": params["bookingResourceId"],
      "FromTime": Time.strptime("#{params['bookingDate']}T#{params['bookingFrom']}","%m/%d/%YT%l:%M %p").utc,
      "ToTime": Time.strptime("#{params['bookingDate']}T#{params['bookingTo']}","%m/%d/%YT%l:%M %p").utc,
      "Online": true
    }
    response = Space.new.create_booking(newBooking.to_json)
    if ( @response = JSON.parse(response.body) ) && @response["WasSuccessful"]
      flash[:notice] = @response["Message"] 
      redirect_to bookings_path
    else
      flash[:alert] = @response["Message"] || "There was an error saving your booking. Please try again."
      redirect_to resources_path
    end
  end

end
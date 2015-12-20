class BookingsController < ApplicationController

  def index 
    @bookings = Booking.new.all_by_coworker("")
  end

  def create 
    newBooking = {
      "ResourceId" => params["bookingResourceId"],
      "FromTime" => Time.strptime("#{params['bookingDate']}T#{params['bookingFrom']}","%m/%d/%YT%l:%M %p").utc,
      "ToTime" => Time.strptime("#{params['bookingDate']}T#{params['bookingTo']}","%m/%d/%YT%l:%M %p").utc,
      "Online" => true
    }
    response = Booking.new.create(newBooking.to_json)
    if ( @response = JSON.parse(response.body) ) && @response["WasSuccessful"]
      flash[:notice] = @response["Message"] 
      redirect_to bookings_path
    else
      flash[:alert] = @response["Message"] || "There was an error saving your booking. Please try again."
      redirect_to resources_path
    end
  end
  
  def destroy
    @bookings = Space.new.bookings_by_user("")
    flash[:info] = "Ability to delete is coming soon!"
    render :index
  end

  def edit
    @bookings = Space.new.bookings_by_user("")
    flash[:info] = "Ability to edit is coming soon!"
    render :index
  end

end
class BookingsController < ApplicationController

  def index 
    @bookings = Booking.all(@coworker.id,[],true)
    @upcoming = @bookings.reject{|b| b.from_time.to_time < Time.now}
    @past = @bookings.reject{|b| b.from_time.to_time > Time.now}
  end

  def create 
    dateTimes = processDateTimes(params['bookingDate'],params['bookingFrom'],params['bookingTo'])

    newBooking = {
      "coworker_id" => @coworker.id,
      "resource_id" => params["bookingResourceId"],
      "from_time" => dateTimes["fromTime"],
      "to_time" => dateTimes["toTime"],
      "online" => true
    }
    booking = Booking.new(newBooking)
    response = booking.create
    if ( @response = JSON.parse(response.body) ) && @response["WasSuccessful"]
      flash[:notice] = @response["Message"] 
      flash[:booking_id] = @response["Value"]["Id"]
      redirect_to resources_path(:anchor => "recurring-container")
    else
      flash[:alert] = @response["Message"] || "There was an error saving your booking. Please try again."
      redirect_to resources_path
    end
  end
  
  def update 
    if params[:booking_repeats].present?
      booking = updateRecurring
      response = booking.create
    else
      dateTimes = processDateTimes(params['bookingDate'],params['bookingFrom'],params['bookingTo'])
      bookingUpdate = {
        "id" => params["bookingId"],
        "coworker_id" => @coworker.id,
        "resource_id" => params["bookingResource"],
        "from_time" => dateTimes["fromTime"],
        "to_time" => dateTimes["toTime"],
        "online" => true
      }
      booking = Booking.new(bookingUpdate)
      response = booking.update
    end

    if ( @response = JSON.parse(response.body) ) && @response["WasSuccessful"]
      flash[:notice] = @response["Message"] 
    else
      flash[:alert] = @response["Message"] || "There was an error updating your booking. Please try again."
    end
    redirect_to bookings_path
  end

  def destroy
    response = Booking.new("id"=>params['id']).destroy
    if ( @response = JSON.parse(response.body) ) && @response["WasSuccessful"]
      flash[:notice] = @response["Message"] 
    else
      flash[:alert] = @response["Message"] || "There was an error canceling your booking. Please contact us."
    end
    redirect_to bookings_path
  end

  def edit 
    @booking = Booking.find(params[:id], :include => "resource")
    respond_to do |format|
      format.js { render :json => @booking }
      format.html { render :index }
    end
  end

  private
  
  def updateRecurring
    oldbooking = Booking.find(params[:id])
    booking = oldbooking
    oldbooking.destroy # Apparently this doesn't work by doing just a plain update, so we have to destroy the old one first 
    booking.id = nil  #...and create a brand new one with the same settings but with recurring added
    booking.repeat_booking = true
    booking.repeats = params[:booking_repeats]
    booking.repeat_every = 1
    booking.repeat_until = (Time.parse(booking.from_time) + (params[:booking_numdays].to_i).days).to_s(:nexudus)
    booking.repeat_on_mondays = params[:booking_repeat_on_mondays] || true
    booking.repeat_on_tuesdays = params[:booking_repeat_on_tuesdays] || true
    booking.repeat_on_wednesdays = params[:booking_repeat_on_wednesdays] || true
    booking.repeat_on_thursdays = params[:booking_repeat_on_thursdays] || true
    booking.repeat_on_fridays = params[:booking_repeat_on_fridays] || true
    booking.repeat_on_saturdays = params[:booking_repeat_on_saturdays] || true
    booking.repeat_on_sundays = params[:booking_repeat_on_sundays] || true
    return booking
  end

  def processDateTimes(day,from,to)
    fromTime = convertToUniversalTime(day,from)
    toTime = convertToUniversalTime(day,to)
    toTime = adjustForNextDay(fromTime,toTime)
    return {
      "fromTime" => fromTime.to_s(:nexudus),
      "toTime" => toTime.to_s(:nexudus)
    }
  end

  def convertToUniversalTime(date,time)
    # Expects both date and time as strings, likely from params
    # Returns time object for further manipulation
    return Time.strptime("#{date}T#{time}","%m/%d/%YT%l:%M %p").utc
  end

  def adjustForNextDay(fromTime,toTime)
    # Expects both as time objects
    # Add one day to toTime if the ending hour is "less" than the starting hour 
    # Fixes for when end-time is in the AM hours of the next day
    # TODO this scrub should really happen on the coffeescript layer before it comes in as input
    # but temporarily fixing it here because it's just easier :P
    toTime += 1.day if toTime < fromTime
    return toTime
  end

end
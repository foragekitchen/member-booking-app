class BookingsController < ApplicationController
  before_action :get_resources, only: [:index]

  def index
    @bookings = Booking.all(@coworker.id,[],true)
    @upcoming = @bookings.reject{|b| b.from_time.to_time < Time.now}
    @past = @bookings.reject{|b| b.from_time.to_time > Time.now}
  end

  def create
    date_times = process_date_times(params['bookingDate'], params['bookingFrom'], params['bookingTo'])

    new_booking = {
        coworker_id: @coworker.id,
        resource_id: params['bookingResourceId'],
        from_time: date_times[:fromTime],
        to_time: date_times[:toTime],
        online: true
    }
    booking = Booking.new(new_booking)
    response = booking.create
    if ( @response = JSON.parse(response.body) ) && @response['WasSuccessful']
      flash[:notice] = @response['Message']
      flash[:booking_id] = @response['Value']['Id']
      redirect_to resources_path(:anchor => 'recurring-container')
    else
      flash[:alert] = @response['Message'] || 'There was an error saving your booking. Please try again.'
      redirect_to resources_path
    end
  end

  def update
    if params[:booking_repeats].present?
      booking = update_recurring
      response = booking.create
    else
      date_times = process_date_times(params['bookingDate'], params['bookingFrom'], params['bookingTo'])
      booking_update = {
          id: params['bookingId'],
          coworker_id: @coworker.id,
          resource_id: params['bookingResource'],
          from_time: date_times[:fromTime],
          to_time: date_times[:toTime],
          online: true
      }
      booking = Booking.new(booking_update)
      response = booking.update
    end

    if ( @response = JSON.parse(response.body) ) && @response['WasSuccessful']
      flash[:notice] = @response['Message']
    else
      flash[:alert] = @response['Message'] || 'There was an error updating your booking. Please try again.'
    end
    redirect_to bookings_path
  end

  def destroy
    response = Booking.new('id' => params['id']).destroy
    if ( @response = JSON.parse(response.body) ) && @response['WasSuccessful']
      flash[:notice] = @response['Message']
    else
      flash[:alert] = @response['Message'] || 'There was an error canceling your booking. Please contact us.'
    end
    redirect_to bookings_path
  end

  def edit
    @booking = Booking.find(params[:id], :include => 'resource')
    respond_to do |format|
      format.js { render :json => @booking }
      format.html { render :index }
    end
  end

  private

  def get_resources
    @resources = Resource.all
  end

  def update_recurring
    old_booking = Booking.find(params[:id])
    booking = old_booking
    old_booking.destroy # Apparently this doesn't work by doing just a plain update, so we have to destroy the old one first
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
    booking
  end

  def process_date_times(day, from, to)
    from_time = convert_to_universal_time(day, from)
    to_time = convert_to_universal_time(day, to)
    to_time = adjust_for_next_day(from_time, to_time)
    {
        fromTime: from_time.to_s(:nexudus),
        toTime: to_time.to_s(:nexudus)
    }
  end

  def convert_to_universal_time(date, time)
    # Expects both date and time as strings, likely from params
    # Returns time object for further manipulation
    Time.strptime("#{date}T#{time}","%m/%d/%YT%l:%M %p").utc
  end

  def adjust_for_next_day(from_time, to_time)
    # Add one day to toTime if the ending hour is "less" than the starting hour
    to_time += 1.day if to_time < from_time
    to_time
  end

end
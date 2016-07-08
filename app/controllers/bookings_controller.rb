class BookingsController < ApplicationController
  before_action :load_resources, only: [:index]

  def index
    @bookings = Booking.all(coworker_id: @coworker.id, include_passed: true)
    @upcoming = @bookings.reject { |b| b.from_time.to_time < Time.now.utc }
    @past = @bookings.reject { |b| b.from_time.to_time > Time.now.utc }
  end

  def create
    date_times = process_date_times(params['bookingDate'], params['bookingFrom'], params['bookingTo'])
    unless current_user.can_book?(date_times[:fromTime], date_times[:toTime])
      flash[:alert] = "You don't have an ability to book tables on this date"
      return redirect_to resources_url
    end
    new_booking = {
      coworker_id: @coworker.id,
      resource_id: params['bookingResourceId'],
      from_time: date_times[:fromTime].to_s(:nexudus),
      to_time: date_times[:toTime].to_s(:nexudus),
      online: true
    }
    booking = Booking.new(new_booking)
    response = booking.create
    if (@response = JSON.parse(response.body)) && @response['WasSuccessful']
      # @todo: we should not allow to invite frined if some maker booked this table already
      if params[:invite_friend] && params[:invite_friend] == 'on' && current_user.maker?
        # Create BookingProduct
        new_booking_product = {
            booking_id: @response['Value']['Id'],
            product_id: BookingProduct.find_invite_friend_plan['Id'],
            quantity: 'False'
        }
        booking_product = BookingProduct.new(new_booking_product)
        booking_product.create
      end
      flash[:notice] = @response['Message']
      flash[:booking_id] = @response['Value']['Id']
      redirect_to resources_url(anchor: 'recurring-container')
    else
      flash[:alert] = 'An error occurred while saving your booking. Please refresh the page and try again.'
      redirect_to resources_url
    end
  end

  def update
    if params[:booking_repeats].present?
      booking = update_recurring
      response = booking.create
    else
      date_times = process_date_times(params['bookingDate'], params['bookingFrom'], params['bookingTo'])
      unless current_user.can_book?(date_times[:fromTime], date_times[:toTime])
        flash[:alert] = "You don't have an ability to book tables on this date"
        return redirect_to resources_url
      end
      booking_update = {
        id: params['bookingId'],
        coworker_id: @coworker.id,
        resource_id: params['bookingResource'],
        from_time: date_times[:fromTime].to_s(:nexudus),
        to_time: date_times[:toTime].to_s(:nexudus),
        online: true
      }
      booking = Booking.new(booking_update)
      response = booking.update
    end

    if (@response = JSON.parse(response.body)) && @response['WasSuccessful']
      flash[:notice] = @response['Message']
    else
      flash[:alert] = 'An error occurred while updating your booking. Please refresh the page and try again.'
    end
    redirect_to bookings_url
  end

  def destroy
    response = Booking.new('id' => params['id']).destroy
    if (@response = JSON.parse(response.body)) && @response['WasSuccessful']
      flash[:notice] = @response['Message']
    else
      flash[:alert] = 'An error occurred while canceling your booking. Please contact us.'
    end
    redirect_to bookings_url
  end

  private

  def load_resources
    @resources = Resource.all
  end

  def update_recurring
    old_booking = Booking.find(params[:id])
    booking = old_booking
    old_booking.destroy # Apparently this doesn't work by doing just a plain update, so we have to destroy the old one first
    booking.id = nil #...and create a brand new one with the same settings but with recurring added
    booking.repeat_booking = true
    booking.repeats = params[:booking_repeats]
    booking.repeat_every = 1
    booking.repeat_until = (Time.parse(booking.from_time) + params[:booking_numdays].to_i.days).to_s(:nexudus)
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
      fromTime: from_time,
      toTime: to_time
    }
  end

  def convert_to_universal_time(date, time)
    # Expects both date and time as strings, likely from params
    # Returns time object for further manipulation
    Time.strptime("#{date}T#{time} #{Time.current.zone}", '%m/%d/%YT%l:%M %p %z').utc
  end

  def adjust_for_next_day(from_time, to_time)
    # Add one day to toTime if the ending hour is "less" than the starting hour
    to_time += 1.day if to_time < from_time
    to_time
  end
end

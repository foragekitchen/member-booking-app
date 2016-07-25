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
    if (response = JSON.parse(response.body)) && response['WasSuccessful']
      session[:last_booking] = {
          id: response['Value']['Id'],
          from_time: date_times[:fromTime].to_s(:google_calendar),
          to_time: date_times[:toTime].to_s(:google_calendar),
          resource: Resource.find(new_booking[:resource_id]).try(:name)
      }
      redirect_to resources_url(anchor: 'recurring-container')
    else
      flash[:alert] = 'An error occurred while saving your booking. Please refresh the page and try again.'
      redirect_to resources_url
    end
  end

  def update
    if params[:booking_dates].present?
      dates = params[:booking_dates].split(';')
      old_booking = Booking.find(params[:id])
      result = true
      dates.each do |date_string|
        booking = update_recurring(old_booking, date_string)
        response = booking.create
        result = result && (response = JSON.parse(response.body)) && response['WasSuccessful']
      end
      if result
        flash[:notice] = "Your #{'booking'.pluralize(dates.count)} #{'was'.pluralize(dates.count)} successfully saved!"
      else
        flash[:alert] = 'Some of your bookings may not be saved because of error'
      end
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
      if (response = JSON.parse(response.body)) && response['WasSuccessful']
        flash[:notice] = response['Message']
      else
        flash[:alert] = 'An error occurred while updating your booking. Please refresh the page and try again.'
      end
    end

    redirect_to bookings_url
  end

  def destroy
    response = Booking.new('id' => params['id']).destroy
    if (response = JSON.parse(response.body)) && response['WasSuccessful']
      flash[:notice] = response['Message']
    else
      flash[:alert] = 'An error occurred while canceling your booking. Please contact us.'
    end
    redirect_to bookings_url
  end

  private

  def load_resources
    @resources = Resource.all
  end

  def update_recurring(old_booking, date_string)
    booking = old_booking.dup
    # Create a brand new one with the same settings but with recurring added
    booking.id = nil
    date = Time.strptime(date_string, Time::DATE_FORMATS[:booking_day]).utc
    change_date = {month: date.month, day: date.day, year: date.year}
    # Change from & to dates for new booking
    [:from_time, :to_time].each { |attr| booking.send("#{attr}=", booking.send(attr).to_datetime.change(change_date)) }
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
    Time.strptime("#{date}T#{time} #{Time.current.zone}", Time::DATE_FORMATS[:universal_date]).utc
  end

  def adjust_for_next_day(from_time, to_time)
    # Add one day to toTime if the ending hour is "less" than the starting hour
    to_time += 1.day if to_time < from_time
    to_time
  end
end

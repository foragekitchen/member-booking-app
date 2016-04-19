class ResourcesController < ApplicationController
  respond_to :html, :json

  def index
    if params[:bookingRequestDate]
      params['bookingRequestFrom'] = "#{params[:bookingRequestDate]}T#{params['bookingRequestFromTime']}"
      params['bookingRequestTo'] = "#{params[:bookingRequestDate]}T#{params['bookingRequestToTime']}"
    end

    if params['bookingRequestFrom'] && params['bookingRequestTo']
      from = Time.strptime(params['bookingRequestFrom'], "%m/%d/%YT%l:%M %p")
      to = Time.strptime(params['bookingRequestTo'], "%m/%d/%YT%l:%M %p")
      to = to + 1.day if to < from

      params['bookingRequestDate'] ||= from.to_s(:booking_day)
      params['bookingRequestFromTime'] ||= from.to_s(:booking_time)
      params['bookingRequestToTime'] ||= to.to_s(:booking_time)

      # 3) Finally, winnow the list further by seeing which ones are not already booked by someone else
      @resources = Resource.all_with_available(from, to)
      # See resources.coffee for where the real action happens
    else
      # 1) Start by getting all the resources ever (regardless of whether they're "open for business" right now)
      @resources = Resource.all

      params['bookingRequestDate'] ||= (Time.current).to_s(:booking_day)
      params['bookingRequestFromTime'] ||= (Time.current + 2.hours).beginning_of_hour.to_s(:booking_time)
      params['bookingRequestToTime'] ||= (Time.current + 6.hours).beginning_of_hour.to_s(:booking_time)
      unless Booking::TIMESLOTS.map(&:strip).include?(params['bookingRequestFromTime']) && Booking::TIMESLOTS.map(&:strip).include?(params['bookingRequestToTime'])
        # @todo: remove hardcode
        params['bookingRequestFromTime'] = ' 8:00 AM'
        params['bookingRequestToTime'] = '12:00 PM'
        params['bookingRequestDate'] = (Time.current + 1.day).to_s(:booking_day) unless Booking::TIMESLOTS.map(&:strip).include?(params['bookingRequestToTime'])
      end
    end

    # respond_to do |format|
    #   format.js { render :index }
    #   format.html { render :index }
    # end
  end

end
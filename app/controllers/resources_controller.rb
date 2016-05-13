class ResourcesController < ApplicationController
  respond_to :html, :json
  before_action :load_date_intervals

  def index
    @resources = (@from_date && @to_date) ? Resource.all_with_available(from_time: @from_date, to_time: @to_date) : Resource.all
  end

  private

  def load_date_intervals
    if params[:bookingRequestFromTime] && params[:bookingRequestToTime]
      @from_date = Time.strptime("#{params[:bookingRequestDate]}T#{params[:bookingRequestFromTime]} #{Time.current.zone}", '%m/%d/%YT%l:%M %p %z')
      @to_date = Time.strptime("#{params[:bookingRequestDate]}T#{params[:bookingRequestToTime]} #{Time.current.zone}", '%m/%d/%YT%l:%M %p %z')
      @to_date += 1.day if @to_date < @from_date
    else
      from = Time.current + 2.hours
      to = from + 4.hours
      params[:bookingRequestDate] = Time.current.to_s(:booking_day)
      params[:bookingRequestFromTime] = from.beginning_of_hour.to_s(:booking_time)
      params[:bookingRequestToTime] = to.beginning_of_hour.to_s(:booking_time)
      if (from.hour < 8 && from.hour > 2) || (to.hour < 8 && to.hour > 2)
        params[:bookingRequestFromTime] = '8:00 AM'
        params[:bookingRequestToTime] = '12:00 PM'
        params[:bookingRequestDate] = to.to_s(:booking_day) if to.hour < 8 || to.hour > 2
      end
    end
  end
end

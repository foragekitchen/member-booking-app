class ResourcesController < ApplicationController

  def index
    @timeslotArray = []
    t = dayStarts = Time.parse("08:00")
    while t <= (dayStarts + 18.hours) do
      @timeslotArray << t.strftime("%l:%M %p")
      t += 30.minutes
    end


    space = Space.new

    if params["bookingRequestFrom"] && params["bookingRequestTo"]
      from = Time.strptime(params["bookingRequestFrom"],"%m/%d/%YT%l:%M %p")
      to = Time.strptime(params["bookingRequestTo"],"%m/%d/%YT%l:%M %p")
      day = from.wday
      offered_resource_ids = space.available_resources_by_day_and_time(day,from,to)
      @resources = space.booked_resources_by_datetime(offered_resource_ids,from,to)

      params["bookingRequestDate"] ||= from.strftime("%m/%d/%Y")
      params["bookingRequestFromTime"] ||= from.strftime("%l:%M %p")
      params["bookingRequestToTime"] ||= to.strftime("%l:%M %p")
    else
      @resources = space.resources

      params["bookingRequestDate"] ||= (Date.today).strftime("%m/%d/%Y")
      params["bookingRequestFromTime"] ||= (Time.now + 2.hours).beginning_of_hour.strftime("%l:%M %p")
      params["bookingRequestToTime"] ||= (Time.now + 6.hours).beginning_of_hour.strftime("%l:%M %p")
    end

    respond_to do |format|
      format.js { render :json => @resources }
      format.html { render :index }
    end
  end

end
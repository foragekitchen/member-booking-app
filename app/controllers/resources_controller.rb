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
      day = Date.parse(params["bookingRequestFrom"]).wday
      offered_resource_ids = space.available_resources_by_day_and_time(day,params["bookingRequestFrom"],params["bookingRequestTo"])
      @resources = space.booked_resources_by_datetime(offered_resource_ids,params["bookingRequestFrom"],params["bookingRequestTo"])

      params["bookingRequestDate"] ||= Date.parse(params["bookingRequestFrom"]).strftime("%m/%d/%Y")
      params["bookingRequestFromTime"] ||= Time.parse(params["bookingRequestFrom"]).strftime("%l:%M %p")
      params["bookingRequestToTime"] ||= Time.parse(params["bookingRequestTo"]).strftime("%l:%M %p")
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
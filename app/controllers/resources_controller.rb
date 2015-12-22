class ResourcesController < ApplicationController

  def index
    @timeslotArray = []
    t = dayStarts = Time.parse("08:00")
    while t <= (dayStarts + 18.hours) do
      @timeslotArray << t.strftime("%l:%M %p")
      t += 30.minutes
    end


    if params["bookingRequestFrom"] && params["bookingRequestTo"]
      from = Time.strptime(params["bookingRequestFrom"],"%m/%d/%YT%l:%M %p")
      to = Time.strptime(params["bookingRequestTo"],"%m/%d/%YT%l:%M %p")

      params["bookingRequestDate"] ||= from.strftime("%m/%d/%Y")
      params["bookingRequestFromTime"] ||= from.strftime("%l:%M %p")
      params["bookingRequestToTime"] ||= to.strftime("%l:%M %p")

      offered_resource_ids = Resource.available_ids(from,to)
      @resources = Resource.booked_ids(from,to,offered_resource_ids)
    else
      @resources = Resource.all

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
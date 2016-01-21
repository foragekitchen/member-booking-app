class ResourcesController < ApplicationController

  def index
    if params["bookingRequestFrom"] && params["bookingRequestTo"]
      from = Time.strptime(params["bookingRequestFrom"],"%m/%d/%YT%l:%M %p")
      to = Time.strptime(params["bookingRequestTo"],"%m/%d/%YT%l:%M %p")

      params["bookingRequestDate"] ||= from.to_s(:booking_day)
      params["bookingRequestFromTime"] ||= from.to_s(:booking_time)
      params["bookingRequestToTime"] ||= to.to_s(:booking_time)

      # 2) Winnow the list of ALL resources down by which ones are "open for business"
      offered_resource_ids = Resource.available_ids(from,to)
      # 3) Finally, winnow the list further by seeing which ones are not already booked by someone else 
      @resources = Resource.booked_ids(from,to,offered_resource_ids)
      # See resources.coffee for where the real action happens
    else
      # 1) Start by getting all the resources ever (regardless of whether they're "open for business" right now)
      @resources = Resource.all

      params["bookingRequestDate"] ||= (Time.now).to_s(:booking_day)
      params["bookingRequestFromTime"] ||= (Time.now + 2.hours).beginning_of_hour.to_s(:booking_time)
      params["bookingRequestToTime"] ||= (Time.now + 6.hours).beginning_of_hour.to_s(:booking_time)
    end

    respond_to do |format|
      format.js { render :json => @resources }
      format.html { render :index }
    end
  end

end
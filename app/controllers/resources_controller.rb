class ResourcesController < ApplicationController

  def index
    params["available"] ||= false
    space = Space.new

    if params["available"]  
      offered_resource_ids = space.available_resources_by_day_and_time()
      @resources = space.booked_resources_by_datetime(offered_resource_ids)
    else
      @resources = space.resources
    end

    respond_to do |format|
      format.js { render :json => @resources }
      format.html { render :index }
    end
  end

end
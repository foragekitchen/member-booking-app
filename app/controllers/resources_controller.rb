class ResourcesController < ApplicationController

  def index
    params["available"] ||= false
    @resources = params["available"] ? Space.new.available_resources_by_day_and_time : Space.new.resources

    respond_to do |format|
      format.js { render :json => @resources }
      format.html { render :index }
    end
  end

end
class BookingsController < ApplicationController

  def index
    @resources = Space.new.resources

    respond_to do |format|
      format.js { render :json => @resources }
      format.html { render :index }
    end
  end

end
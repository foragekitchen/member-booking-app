class BookingsController < ApplicationController

  def index
    @resources = Space.new.resources
  end

end
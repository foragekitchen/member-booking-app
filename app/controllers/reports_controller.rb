class ReportsController < ApplicationController
  # TODO: make special auth
  def index
    @bookings = Booking.all_for_all_users
  end
end
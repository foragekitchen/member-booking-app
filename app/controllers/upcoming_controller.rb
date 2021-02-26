class UpcomingController < ApplicationController
  before_action :load_resources, only: [:index]

  # TODO: filter by resource type if system uses different resource types later
  def index
    if params[:fromDate] == '' || params[:toDate] == ''
      flash[:alert] = 'Please choose the date range'
      return redirect_to upcoming_bookings_url
    end

    build_date_params
    @bookings = Booking.all(
      coworker_id: nil, resource_ids: [],
      options: { from_time: @from_time, to_time: @to_time }
    ).sort_by(&:from_time)
  end

  private

  def build_date_params
    @from_time = DateTime.now
    if params[:fromDate].present?
      @from_time = DateTime.strptime("#{params[:fromDate]} 00:00:00", '%m/%d/%Y %H:%M:%S')
      @from_time = DateTime.now if @from_time < DateTime.now
    end
    @to_time = if params[:toDate].present?
                 DateTime.strptime("#{params[:toDate]} 23:59:59", '%m/%d/%Y %H:%M:%S')
               else
                 DateTime.now + 7.days
               end
  end

  def load_resources
    @resources = Resource.all(role: current_user.role)
  end
end

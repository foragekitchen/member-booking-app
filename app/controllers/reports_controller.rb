class ReportsController < ApplicationController

  def index
    result = {}
    bookings = Booking.all_for_all_users(params[:from], params[:to])
    bookings.each do |booking|
      resource_type = booking.resource.resource_type_name
      # TODO: make more flexible
      amount = case
                 when resource_type == 'Prep Table' then 1
                 when resource_type == 'Prep Station' then 2
                 else
                   14
               end
      from = DateTime.parse(booking.from_time)
      to = DateTime.parse(booking.to_time)
      if from.minute == 15
        from += 15.minutes
      end
      if to.minute == 15
        to += 15.minutes
      end
      while from < to
        result[from.to_s] = result[from.to_s].nil? ? amount : result[from.to_s] += amount
        from += 30.minutes
      end
      # TODO: add empty timestamps
    end
    render json: result
  end
end
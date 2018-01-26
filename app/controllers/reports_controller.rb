class ReportsController < ApplicationController
  START_TIME = DateTime.parse('01-11-2017 00:00:00').freeze
  # TODO: make special auth
  def index
    result = {}
    starts_of_week = []
    start_of_week = START_TIME - START_TIME.wday
    while start_of_week < DateTime.now
      starts_of_week << start_of_week
      start_of_week += 7.days
    end
    bookings = Booking.all_for_all_users
    bookings.each do |booking|
      resource_type = booking.resource.resource_type_name
      # TODO: make more flexible
      amount = case
                 when resource_type == 'Prep Table' then 1
                 when resource_type == 'Prep Station' then 2
                 else
                   14
               end
      # from_timestamp = booking.from_time.to_datetime.to_i
      # to_timestamp = booking.to_time.to_datetime.to_i
      from = DateTime.parse(booking.from_time)
      to = DateTime.parse(booking.to_time)
      if from.minute == 15
        from += 15.minutes
      end
      if to.minute == 15
        to += 15.minutes
      end
      # TODO: clarify about include to datetime
      while from < to
        result[from.to_s] = result[from.to_s].nil? ? amount : result[from.to_s] += amount
        from += 30.minutes
      end
      # TODO: add empty timestamps, divide by weeks
    end
    render json: result
  end
end
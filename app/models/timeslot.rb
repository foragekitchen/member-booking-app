class Timeslot < NexudusBase
  REQUEST_URI = '/spaces/resourcetimeslots'

  def self.all_by_day(day_of_week = Date.today.wday)
    query_params = {'ResourceTimeSlot_DayOfWeek' => day_of_week}
    result = Rails.cache.fetch([REQUEST_URI, query_params], :expires => 12.hours) do
      get(REQUEST_URI, :query => query_params)['Records']
    end
    result
  end

  def self.available(from_time = Time.now + 2.hours, to_time = Time.now + 6.hours)
    from_time = Time.parse(from_time) if from_time.is_a?(String) #just in case; this should already be in correct Time format
    to_time = Time.parse(to_time) if to_time.is_a?(String) #just in case; this should already be in correct Time format
    requested_date = from_time.to_date
    day_of_week = from_time.wday

    set = all_by_day(day_of_week)

    available = []
    set.each do |time_slot|
      # Let's reset the weird database date (ex. "1976-01-01T00:59:00Z") to current year/month/day,
      # accounting for daylight savings time (offset of 7 vs 8 hrs, depending on time of year)
      slot_date = Date.parse(time_slot['FromTime'])
      seconds_diff = (requested_date.to_time - slot_date.to_time)

      slot_start = Time.parse(time_slot['FromTime']) + seconds_diff
      slot_end = Time.parse(time_slot['ToTime']) + seconds_diff

      available << time_slot if from_time.utc >= slot_start && to_time.utc <= slot_end
    end
    available
  end

end
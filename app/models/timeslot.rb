class Timeslot < NexudusBase
  REQUEST_URI = '/spaces/resourcetimeslots'.freeze

  class << self
    def all_by_day(day_of_week = Time.zone.today.wday)
      query_params = { ResourceTimeSlot_DayOfWeek: day_of_week, size: 100 }
      result = Rails.cache.fetch([REQUEST_URI, query_params], expires: 12.hours) do
        get(REQUEST_URI, query: query_params)['Records']
      end
      result
    end

    def available(from_time: Time.current + 2.hours, to_time: Time.current + 4.hours)
      from_time = Time.parse(from_time) if from_time.is_a?(String) # just in case; this should already be in correct Time format
      to_time = Time.parse(to_time) if to_time.is_a?(String) # just in case; this should already be in correct Time format

      is_from_midnight = from_time == from_time.midnight

      slots = all_by_day(from_time.wday)
      available = []

      normalize_slots(slots).flatten.each do |time_slot|
        slot_start = Time.zone.parse(time_slot['FromTime'])
        slot_end = Time.zone.parse(time_slot['ToTime'])
        delta = (from_time.to_date - slot_start.to_date).days - (is_from_midnight ? 1 : 0).day
        slot_start += delta
        slot_end += delta + (from_time.yday < to_time.yday || from_time.year < to_time.year || is_from_midnight ? 1 : 0).day

        available << time_slot if slot_start <= from_time && slot_end >= to_time
      end
      available
    end

    private

    def normalize_slots(slots)
      slots.each do |time_slot|
        to = Time.parse(time_slot['ToTime'])
        time_slot['ToTime'] = (to + 1.minute).to_s if to.min == 59
      end
    end
  end
end

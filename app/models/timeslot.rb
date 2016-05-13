class Timeslot < NexudusBase
  REQUEST_URI = '/spaces/resourcetimeslots'.freeze

  class << self
    def all_by_day(day_of_week = Time.zone.today.wday)
      query_params = { ResourceTimeSlot_DayOfWeek: day_of_week }
      result = Rails.cache.fetch([REQUEST_URI, query_params], expires: 12.hours) do
        get(REQUEST_URI, query: query_params)['Records']
      end
      result
    end

    def available(from_time: Time.current + 2.hours, to_time: Time.current + 6.hours)
      from_time = Time.parse(from_time) if from_time.is_a?(String) # just in case; this should already be in correct Time format
      to_time = Time.parse(to_time) if to_time.is_a?(String) # just in case; this should already be in correct Time format
      from_time_from_day_beginning = from_time.to_f - from_time.change(hour: 0, min: 0).to_f
      to_time_from_day_beginning = to_time.to_f - from_time.change(hour: 0, min: 0).to_f

      slots = all_by_day(from_time.wday)
      available = []

      normalize_slots(slots).flatten.each do |time_slot|
        slot_date = Date.parse(time_slot['FromTime'])

        slot_start = Time.zone.parse(time_slot['FromTime'])
        slot_end = Time.zone.parse(time_slot['ToTime'])
        start_from_beginning = slot_start.to_f - slot_start.change(hour: 0, min: 0).to_f
        end_from_beginning = slot_end.to_f - slot_start.change(hour: 0, min: 0).to_f

        available << time_slot if from_time_from_day_beginning >= start_from_beginning && to_time_from_day_beginning <= end_from_beginning
      end
      available
    end

    private

    def normalize_slots(slots)
      grouped = Hash.new { |hash, key| hash[key] = [] }
      slots.each do |time_slot|
        to = Time.parse(time_slot['ToTime'])
        time_slot['ToTime'] = (to + 1.minute).to_s if to.min == 59
        grouped[time_slot['ResourceId']] << time_slot
      end

      res = []
      grouped.each do |_, grouped_slots|
        grouped_slots = grouped_slots.sort_by { |time_slot| Time.parse(time_slot['FromTime']) }
        index = 0
        loop do
          break if !grouped_slots[index + 1] || index >= grouped_slots.size
          if Time.parse(grouped_slots[index]['FromTime']).to_s(:booking_time) == Time.parse(grouped_slots[index + 1]['ToTime']).to_s(:booking_time)
            to = Time.parse(grouped_slots[index]['ToTime'])
            to += 1.day if to.day != Time.parse(grouped_slots[index + 1]['ToTime']).day
            grouped_slots[index + 1]['ToTime'] = to.to_s
            grouped_slots.delete_at(index)
            index = -1
          end
          index += 1
        end
        res << grouped_slots
      end
      res.flatten
    end
  end
end

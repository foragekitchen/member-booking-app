class Space < NexudusBase

  class << self

  def booked_resources_by_datetime(resource_ids = [], from_time = Time.now + 2.hours, to_time = Time.now + 6.hours)
    from_time = Time.parse(from_time) if from_time.is_a?(String) #just in case; this should already be in correct Time format
    to_time = Time.parse(to_time) if to_time.is_a?(String) #just in case; this should already be in correct Time format
    from_time.utc
    to_time.utc

    results = Booking.all("",resource_ids)
    set = resource_ids
    
    results.each do |booking|
      next unless set.include? booking["ResourceId"]
      set.delete(booking["ResourceId"]) if booking["FromTime"] >= from_time && booking["ToTime"] <= to_time # falls exactly inside the slot
      set.delete(booking["ResourceId"]) if booking["FromTime"] >= from_time && booking["FromTime"] < to_time # overlaps after requested start
      set.delete(booking["ResourceId"]) if booking["FromTime"] <= from_time && booking["ToTime"] > from_time # overlaps before requested start
    end

    return set 
  end
  
  end

end
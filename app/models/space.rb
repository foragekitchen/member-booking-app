class Space < NexudusBase

  def get_resource(id)
    self.class.get("/spaces/resources/#{id}")
  end

  def resource_details(id)
    # We can only access the "Description", AND the "LinkedResources" data when calling a single Resource
    resource = get_resource(id)
    details = {:description => resource["Description"]}
    linked = resource["LinkedResources"].present? ? get_resource( resource["LinkedResources"].first ) : nil
    
    if linked.present?
      location = linked["Description"].include?("@") ? linked["Description"].split("@").last.split(",") : nil
      location.map!{ |ft| ResourceLocation.new.convert_from_feet_to_inches(ft) } if location.is_a?(Array)
      details.merge!({:location => location})
    end

    return details
  end

  def resources(type = "Prep Table", visible = true)
    results = self.class.get("/spaces/resources?Resource_Visible=#{visible}")["Records"]
    resources = []

    results.each do |r|
      next unless r["ResourceTypeName"] == type
      item = {
        :id => r["Id"], 
        :name => r["Name"], 
        :type => r["ResourceTypeName"]
      }
      item.merge!( resource_details(r["Id"]) )
      resources << item
    end
    
    return resources
  end

  def available_resources_by_day(day_of_week)
    # We have to figure out time-availability ourselves, since the 'ResourceTimeSlot_FromTime' only returns exact matches
    self.class.get("/spaces/resourcetimeslots?ResourceTimeSlot_DayOfWeek=#{day_of_week}")["Records"]
  end

  def available_resources_by_time(set, from_time, to_time)
    from_time = Time.parse(from_time) if from_time.is_a?(String)
    to_time = Time.parse(to_time) if to_time.is_a?(String)
    requested_date = from_time.utc.to_date

    available = []
    set.each do |time_slot|
      # Let's reset the weird database date (ex. "1976-01-01T00:59:00Z") to current year/month/day
      slot_date = Date.parse(time_slot["FromTime"])
      date_diff = requested_date - slot_date 
      seconds_diff = date_diff * 24 * 60 * 60
      
      slot_start = Time.parse(time_slot["FromTime"]) + seconds_diff
      slot_end = Time.parse(time_slot["ToTime"]) + seconds_diff

      available << time_slot if from_time.utc >= slot_start && to_time.utc <= slot_end
    end
    
    return available

  end

  def available_resources_by_day_and_time(day_of_week = Date.today.wday,from_time = Time.now + 2.hours, to_time = Time.now + 6.hours)
    results = available_resources_by_time(available_resources_by_day(day_of_week),from_time,to_time)
    return results.collect{|t| t["ResourceId"]}
  end

  def bookings(resources = [])
    result = []
    resources.each do |id|
      result << self.class.get("/spaces/bookings?Booking_Resource=#{id}")["Records"]
    end
    return result.flatten.reject &:blank?
  end

  def booked_resources_by_datetime(resources = [], from_time = Time.now + 2.hours, to_time = Time.now + 6.hours)
    from_time = DateTime.parse(from_time).utc if from_time.is_a?(String)
    to_time = DateTime.parse(to_time).utc if to_time.is_a?(String)

    results = bookings(resources)
    set = resources
    
    results.each do |booking|
      next unless set.include? booking["ResourceId"]
      set.delete(booking["ResourceId"]) if booking["FromTime"] >= from_time && booking["ToTime"] <= to_time # falls exactly inside the slot
      set.delete(booking["ResourceId"]) if booking["FromTime"] >= from_time && booking["FromTime"] <= to_time # overlaps after requested start
      set.delete(booking["ResourceId"]) if booking["FromTime"] <= from_time && booking["ToTime"] >= from_time # overlaps before requested start
    end

    return set 
  end
  

end
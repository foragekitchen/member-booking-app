class Resource < NexudusBase
  attr_accessor :id, :description, :linked_resources, :location, :name, :resource_type_name, :timeslots, :visible
  @@resource_uri = "/spaces/resources"

  def initialize(params)
    params.map do |k,v|
      attribute_name = k.underscore
      public_send("#{k.underscore}=", v) if respond_to?(attribute_name)
    end
  end

  def self.all(type = "Prep Table", visible = true, location = true)
    results = get(@@resource_uri+"?Resource_Visible=#{visible}")["Records"]
    resources = []

    results.each do |r|
      next unless r["ResourceTypeName"] == type

      resource_with_details = find(r["Id"])
      resource_with_details.id = r["Id"] #TODO - find better way for rspec; this is purely to help with rspec because every single-resource returns same id
      if location && resource_with_details.linked_resources.present?
        resource_with_details.location = get_location_of_linked(resource_with_details.linked_resources.first)
      end

      resources << resource_with_details
    end
    
    return resources      
  end

  def self.available_ids(from_time = Time.now + 2.hours, to_time = Time.now + 6.hours)
    timeslots = Timeslot.available(from_time,to_time)
    resource_ids = timeslots.collect{|t| t["ResourceId"]}.uniq
  end

  def self.find(id)
    result = get(@@resource_uri+"/#{id}").parsed_response
    resource = new(result)
  end

  def self.get_location_of_linked(id)
    linked = find(id)
    if linked.present?
      location = linked.description.include?("@") ? linked.description.split("@").last.split(",") : nil
      location.map!{ |ft| ResourceLocation.new.convert_from_feet_to_inches(ft) } if location.is_a?(Array)
    end
    return location || nil
  end

end
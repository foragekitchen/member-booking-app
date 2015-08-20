class Space < NexudusBase

  def get_resource(id)
    self.class.get("/spaces/resources/#{id}")
  end

  def get_category(type_name = "Cooking Blocks")
    # Get the ResourceTypeID of the kind of resource we want, so we can filter by it 
  end

  def resource_location(id)
    # We can only access the "Description", AND the "LinkedResources" data when calling a single Resource
    resource = get_resource(id)
    linked = resource["LinkedResources"].present? ? get_resource( resource["LinkedResources"].first ) : nil
    
    if linked.present?
      location = linked["Description"].include?("@") ? linked["Description"].split("@").last.split(",") : nil
      location.map!{ |ft| ResourceLocation.new.convert_from_feet_to_inches(ft) } if location.is_a?(Array)
    else
      return nil
    end
  end

  def resources(type = "Cooking Blocks", visible = true)
    results = self.class.get("/spaces/resources?Resource_Visible=#{visible}")["Records"]
    resources = []

    results.each do |r|
      next unless r["ResourceTypeName"] == type
      item = {:id => r["Id"], :name => r["Name"], :type => r["ResourceTypeName"], :location => resource_location(r["Id"])}
      resources << item
    end
    
    return resources
  end

end
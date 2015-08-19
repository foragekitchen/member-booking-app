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
    linked = get_resource(resource["LinkedResources"].try("first")) || { "Description" => nil }
    
    return linked["Description"]
  end

  def resources(type = "Cooking Blocks", visible = true)
    results = self.class.get("/spaces/resources?Resource_Visible=#{visible}")["Records"]
    resources = []

    results.each do |r|
      next unless r["ResourceTypeName"] == type
      item = {:id => r["Id"], :name => r["Name"], :location => resource_location(r["Id"])}
      resources << item
    end
    
    return resources
  end

end
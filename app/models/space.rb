class Space < NexudusBase

  def get_resource(id)
    self.class.get("/spaces/resources/#{id}")
  end

  def resource_location(id)
    # We can only access the "Description", AND the "LinkedResources" data when calling a single Resource
    resource = get_resource(id)
    linked = get_resource(resource["LinkedResources"].try("first")) || { "Description" => nil }
    
    return linked["Description"]
  end

  def resources
    type = "Cooking Blocks"
    type = 41037021
    results = self.class.get("/spaces/resources?Resource_ResourceType=#{type}")["Records"]
    resources = []

    results.each do |r|
      item = {:id => r["Id"], :name => r["Name"], :location => resource_location(r["Id"])}
      resources << item
    end
    
    return resources
  end

end
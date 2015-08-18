class Space < Nexudus

  def resources(id=nil)
    results = self.class.get("/spaces/resources/#{id}")
    if id
      results
    else
      results["Records"]
    end
  end

end
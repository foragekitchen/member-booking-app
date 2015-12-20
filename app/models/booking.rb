class Booking < NexudusBase

  def all_by_coworker(coworker_id="")
    self.class.get("/spaces/bookings?Booking_Coworker=#{coworker_id}")["Records"]
  end

  def all_by_resource(resources = [])
    result = []
    resources.each do |id|
      result << self.class.get("/spaces/bookings?Booking_Resource=#{id}")["Records"]
    end
    return result.flatten.reject &:blank?
  end

  def create(json_hash)
    self.class.post("/spaces/bookings", :body => json_hash, :headers => { 'Content-Type' => 'application/json' })
  end

end
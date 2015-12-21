class Booking < NexudusBase

  @@request_uri = "/spaces/bookings"

  class << self

    def all(coworkerID="", resources=[])
      request_param = coworkerID.present? ? ["Booking_Coworker=#{coworker_id}"] : []
      result = []
      if resources.present?
        resources.each do |id|
          result << get(@@request_uri+(request_param + ["Booking_Resource=#{id}"]).join("&"))["Records"]
        end
      else
        result << get(@@request_uri)["Records"]
      end
      return result.flatten.reject &:blank?
    end

  end


  def create(json_hash)
    self.class.post(@@request_uri, :body => json_hash, :headers => { 'Content-Type' => 'application/json' })
  end

end
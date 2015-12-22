class Booking < NexudusBase

  @@request_uri = "/spaces/bookings?"

  def self.all(coworkerID="", resource_ids=[], include_passed=false)
    request_params = []
    request_params += ["Booking_Coworker=#{coworker_id}"] if coworkerID.present?
    request_params += ["Booking_Invoiced=false"] unless include_passed # Relies on 'Booking_Invoiced' to guess at whether it's passed or future; maybe there is/will be a better way from Nexudus API

    bookings = []
    if resource_ids.present?
      resource_ids.uniq.each do |id|
        bookings << get(@@request_uri+(request_params + ["Booking_Resource=#{id}"]).join("&"))["Records"]
      end
    else
      bookings << get(@@request_uri+request_params.join("&"))["Records"]
    end
    bookings = bookings.flatten.reject &:blank?
    bookings = bookings.sort_by{|b| b["FromTime"]}
    return bookings.reverse
  end

  def create(json_hash)
    self.class.post(@@request_uri, :body => json_hash, :headers => { 'Content-Type' => 'application/json' })
  end

end
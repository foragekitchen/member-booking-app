class Booking < NexudusBase
  attr_accessor :id, :resource_id, :from_time, :to_time, :online
  @@request_uri = "/spaces/bookings"

  def initialize(params)
    params.map do |k,v|
      attribute_name = k.underscore
      public_send("#{k.underscore}=", v) if respond_to?(attribute_name)
    end
  end

  def self.all(coworkerID="", resource_ids=[], include_passed=false)
    request_params = []
    request_params += ["Booking_Coworker=#{coworker_id}"] if coworkerID.present?
    request_params += ["Booking_Invoiced=false"] unless include_passed # Relies on 'Booking_Invoiced' to guess at whether it's passed or future; maybe there is/will be a better way from Nexudus API

    bookings = []
    if resource_ids.present?
      resource_ids.uniq.each do |id|
        result = get(@@request_uri+"?"+(request_params + ["Booking_Resource=#{id}"]).join("&"))["Records"]
        bookings << result.map{|b| new(b) }
      end
    else
      bookings << get(@@request_uri+"?"+request_params.join("&"))["Records"].map{|b| new(b)}
    end
    bookings = bookings.flatten.reject &:blank?
    bookings = bookings.sort_by{|b| b.from_time}
    return bookings.reverse
  end

  def create
    attrs = Hash[instance_variables.map! { |name| [name.to_s.gsub(/@/,'').classify, instance_variable_get(name)] } ]
    self.class.post(@@request_uri, :body => attrs.to_json, :headers => { 'Content-Type' => 'application/json' })
  end

  def destroy
    self.class.delete(@@request_uri+"/#{id}")
  end

  def resource
    Resource.find(resource_id)
  end

end
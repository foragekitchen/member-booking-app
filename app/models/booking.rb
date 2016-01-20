class Booking < NexudusBase
  attr_accessor :id, :resource_id, :coworker_id, :from_time, :to_time, :online
  @@request_uri = "/spaces/bookings"

  TIMESLOTS = ["8:00 AM", "8:30 AM", "9:00 AM", "9:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM", "12:00 PM", "12:30 PM", "1:00 PM", "1:30 PM", "2:00 PM", "2:30 PM", "3:00 PM", "3:30 PM", "4:00 PM", "4:30 PM", "5:00 PM", "5:30 PM", "6:00 PM", "6:30 PM", "7:00 PM", "7:30 PM", "8:00 PM", "8:30 PM", "9:00 PM", "9:30 PM", "10:00 PM", "10:30 PM", "11:00 PM", "11:30 PM", "12:00 AM", "12:30 AM", "1:00 AM", "1:30 AM", "2:00 AM"]

  def initialize(params)
    params.map do |k,v|
      attribute_name = k.underscore
      public_send("#{k.underscore}=", v) if respond_to?(attribute_name)
    end
  end

  def self.all(coworker_id="", resource_ids=[], include_passed=false)
    request_params = []
    request_params += ["Booking_Coworker=#{coworker_id}"] if coworker_id.present?
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
    return bookings
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
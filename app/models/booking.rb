class Booking < NexudusBase
  attr_accessor :id, :resource_id, :resource_name, :coworker_id, :coworker_full_name, :from_time, :to_time, :online, :updated_by, :friendly_start_date, :friendly_dates, :friendly_times
  @@request_uri = "/spaces/bookings"

  TIMESLOTS = ["8:00 AM", "8:30 AM", "9:00 AM", "9:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM", "12:00 PM", "12:30 PM", "1:00 PM", "1:30 PM", "2:00 PM", "2:30 PM", "3:00 PM", "3:30 PM", "4:00 PM", "4:30 PM", "5:00 PM", "5:30 PM", "6:00 PM", "6:30 PM", "7:00 PM", "7:30 PM", "8:00 PM", "8:30 PM", "9:00 PM", "9:30 PM", "10:00 PM", "10:30 PM", "11:00 PM", "11:30 PM", "12:00 AM", "12:30 AM", "1:00 AM", "1:30 AM", "2:00 AM"]

  include ActionView::Helpers::TextHelper

  def initialize(params)
    params.map do |k,v|
      attribute_name = k.underscore
      public_send("#{attribute_name}=", v) if respond_to?(attribute_name)
    end
    public_send("friendly_dates=", friendly_dates)
    public_send("friendly_times=", friendly_times)
  end

  def self.find(id)
    booking = get(@@request_uri+"/#{id}").parsed_response
    return new(booking)
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

  def friendly_dates
    str = ""
    from = Time.parse(from_time).localtime
    to = Time.parse(to_time).localtime
    days = ((to - from) / 1.day).to_i

    if from >= Time.now && from < Time.now + 3.days
      str += "In #{time_ago_in_words(from)}"
      str += " (#{from.to_s(:booking_short)})"
    else 
      str += from.to_s(:booking)
    end
    str += " (#{pluralize(days, "day")})" if days > 1
    
    return str
  end

  def friendly_times
    return Time.parse(from_time).localtime.strftime("%l:%M %p").strip + " - " + Time.parse(to_time).localtime.strftime("%l:%M %p").strip
  end


end
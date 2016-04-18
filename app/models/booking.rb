class Booking < NexudusBase
  attr_accessor :id, :resource_id, :resource_name, :resource, :coworker_id, :coworker_full_name, :from_time, :to_time, :online, :updated_by, :friendly_start_date, :friendly_dates, :friendly_date, :friendly_times, :duration_in_minutes, :repeat_series_unique_id, :repeat_booking, :repeats, :repeat_every, :repeat_until, :repeat_on_mondays, :repeat_on_tuesdays, :repeat_on_wednesdays, :repeat_on_thursdays, :repeat_on_fridays, :repeat_on_saturdays, :repeat_on_sundays
  REQUEST_URI = '/spaces/bookings'

  TIMESLOTS = [' 8:00 AM', ' 8:30 AM', ' 9:00 AM', ' 9:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM', ' 1:00 PM', ' 1:30 PM', ' 2:00 PM', ' 2:30 PM', ' 3:00 PM', ' 3:30 PM', ' 4:00 PM', ' 4:30 PM', ' 5:00 PM', ' 5:30 PM', ' 6:00 PM', ' 6:30 PM', ' 7:00 PM', ' 7:30 PM', ' 8:00 PM', ' 8:30 PM', ' 9:00 PM', ' 9:30 PM', '10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM', '12:00 AM', '12:30 AM', ' 1:00 AM', ' 1:30 AM', ' 2:00 AM']

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper

  def initialize(params)
    params.map do |k, v|
      attribute_name = k.to_s.underscore
      public_send("#{attribute_name}=", v) if respond_to?(attribute_name)
    end
    if self.from_time.present? # protect against the times we're just quick-instantiating for a destroy
      load_friendly_dates
      load_friendly_times
      load_friendly_date
      load_duration_in_minutes
    end
  end

  class << self
    def find(id, options = {})
      booking = get("#{REQUEST_URI}/#{id}").parsed_response
      booking = new(booking)
      booking.public_send('resource=', booking.resource) if options[:include].present?
      booking
    end

    def all(coworker_id = nil, resource_ids = [], include_passed = nil)
      params = []
      params << "Booking_Coworker=#{coworker_id}" if coworker_id.present?
      params << 'Booking_Invoiced=false' unless include_passed # Relies on 'Booking_Invoiced' to guess at whether it's passed or future; maybe there is/will be a better way from Nexudus API

      bookings = []
      resource_ids.uniq.each do |id|
        result = get("#{REQUEST_URI}?#{(params + ["Booking_Resource=#{id}"]).join('&')}")['Records']
        bookings << result.map{|b| new(b) }
      end
      bookings = get("#{REQUEST_URI}?#{params.join('&')}")['Records'].map{ |b| new(b) } unless resource_ids.present?
      bookings.flatten.reject(&:blank?).sort_by{ |b| b.from_time }
    end
  end

  def create
    attrs = Hash[ instance_variables.map! { |name| [name.to_s.gsub(/@/,'').classify, instance_variable_get(name)] } ]
    attrs = Hash[ attrs.map { |k, v| [k.start_with?('RepeatOn') || k == 'Repeat' ? k.pluralize : k, v] } ]
    self.class.post(REQUEST_URI, body: attrs.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def update
    attrs = Hash[instance_variables.map! { |name| [name.to_s.gsub(/@/,'').classify, instance_variable_get(name)] } ]
    self.class.put(REQUEST_URI, body: attrs.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def destroy
    self.class.delete("#{REQUEST_URI}/#{id}")
  end

  def resource
    Resource.find(resource_id)
  end

  def formatted_from_time
    Time.parse(from_time).localtime.to_s(:booking_time)
  end

  def formatted_to_time
    Time.parse(to_time).localtime.to_s(:booking_time)
  end

  private
  def load_friendly_dates
    from = Time.parse(from_time).localtime
    to = Time.parse(to_time).localtime
    days = ((to - from) / 1.day).to_i

    if from >= Time.now && from < Time.now + 3.days
      self.friendly_dates = "In #{time_ago_in_words(from)} (#{from.to_s(:booking_short)})"
    else
      self.friendly_dates = from.to_s(:booking)
    end
    self.friendly_dates = "#{self.friendly_dates} (#{pluralize(days, 'day')})" if days > 1
  end

  def load_friendly_times
    self.friendly_times = "#{formatted_from_time} - #{formatted_to_time}"
  end

  def load_friendly_date
    self.friendly_date = Time.parse(self.from_time).to_s(:booking_day)
  end

  def load_duration_in_minutes
    self.duration_in_minutes = (Time.parse(to_time) - Time.parse(from_time)) / 60
  end

end
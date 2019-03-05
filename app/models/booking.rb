class Booking < NexudusBase
  attr_accessor :id, :resource_id, :resource_name, :resource, :coworker_id,
                :coworker_full_name, :from_time, :to_time, :online, :updated_by,
                :friendly_start_date, :friendly_dates, :friendly_date, :friendly_times,
                :friendly_from_time, :friendly_to_time, :duration_in_minutes,
                :repeat_series_unique_id, :repeat_booking, :repeats, :repeat_every,
                :repeat_until, :repeat_on_mondays, :repeat_on_tuesdays, :repeat_on_wednesdays,
                :repeat_on_thursdays, :repeat_on_fridays, :repeat_on_saturdays, :repeat_on_sundays
  REQUEST_URI = '/spaces/bookings'.freeze
  # TODO: implement pagination handling
  PAGE_SIZE = '&size=200'
  ORDERING = '&orderby=FromTime&dir=Descending'

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper

  def initialize(params)
    super
    if from_time.present? # protect against the times we're just quick-instantiating for a destroy
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

    def all(coworker_id: nil, resource_ids: [], options: {})
      params = []
      params << "Booking_Coworker=#{coworker_id}" if coworker_id.present?
      # Expand booking time search boundaries a little bit if we have them
      if options[:from_time]
        options[:from_time] -= 1.day if options[:from_time] == options[:from_time].to_date.beginning_of_day
        params << "From_Booking_FromTime=#{options[:from_time].change(hour: 1, minutes: 0).utc.to_s(:nexudus)}"
      end
      params << "To_Booking_FromTime=#{options[:to_time].in(1.hour).utc.to_s(:nexudus)}" if options[:to_time]

      bookings = []
      resource_ids.uniq.each do |id|
        result = get("#{REQUEST_URI}?#{(params + ["Booking_Resource=#{id}"]).join('&')}")['Records']
        bookings << result.map { |b| new(b) }
      end
      bookings = get("#{REQUEST_URI}?#{params.join('&')}#{PAGE_SIZE}#{ORDERING}")['Records'].map { |b| new(b) } unless resource_ids.present?
      bookings.flatten.reject(&:blank?)
    end

    def upcoming_uncharged(coworker_id)
      params = []
      params << 'Booking_Invoiced=false'
      params << "Booking_Coworker=#{coworker_id}" if coworker_id.present?
      params << "From_Booking_FromTime=#{DateTime.now.utc.to_s(:nexudus)}"

      bookings = get("#{REQUEST_URI}?#{params.join('&')}")
      bookings = bookings ? bookings['Records'].map { |b| new(b) } : []
      bookings.flatten.reject(&:blank?).sort_by(&:from_time)
    end
  end

  def create
    attrs = Hash[instance_variables.map! { |name| [name.to_s.gsub(/@/, '').classify, instance_variable_get(name)] }]
    attrs = Hash[attrs.map { |k, v| [k.start_with?('RepeatOn') || k == 'Repeat' ? k.pluralize : k, v] }]
    self.class.post(REQUEST_URI, body: attrs.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def update
    attrs = Hash[instance_variables.map! { |name| [name.to_s.gsub(/@/, '').classify, instance_variable_get(name)] }]
    self.class.put(REQUEST_URI, body: attrs.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def destroy
    self.class.delete("#{REQUEST_URI}/#{id}")
  end

  def resource
    Resource.find(resource_id)
  end

  def formatted_from_time
    Time.zone.parse(from_time).to_s(:booking_time)
  end

  def formatted_to_time
    Time.zone.parse(to_time).to_s(:booking_time)
  end

  private

  def load_friendly_dates
    from = Time.zone.parse(from_time)
    to = Time.zone.parse(to_time)
    days = ((to - from) / 1.day).to_i

    if from >= Time.current && from < Time.current + 3.days
      self.friendly_dates = "In #{time_ago_in_words(from)} (#{from.to_s(:booking_short)})"
    else
      self.friendly_dates = from.to_s(:booking)
    end
    self.friendly_dates = "#{friendly_dates} (#{pluralize(days, 'day')})" if days > 1
  end

  def load_friendly_times
    self.friendly_from_time = formatted_from_time.strip
    self.friendly_to_time = formatted_to_time.strip
    self.friendly_times = "#{friendly_from_time} - #{friendly_to_time}"
  end

  def load_friendly_date
    self.friendly_date = Time.zone.parse(from_time).to_s(:booking_day)
  end

  def load_duration_in_minutes
    self.duration_in_minutes = (Time.zone.parse(to_time) - Time.zone.parse(from_time)) / 60
  end
end

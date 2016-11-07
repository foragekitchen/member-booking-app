class Coworker < NexudusBase
  attr_accessor :id, :user_id, :email, :full_name, :salutation, :active, :next_tariff_id
  REQUEST_URI = '/spaces/coworkers'.freeze
  BILLING_URI = '/billing/coworkerextraservices'.freeze
  BILLING_PLANS_URI = '/billing/tariffs'.freeze

  class << self
    def find_by_user(user_id, query = {})
      # Find by UserId since it's all we have so far
      query_params = { Coworker_User: user_id }.merge(query)
      results = Rails.cache.fetch([REQUEST_URI, query_params], expires: 24.hours) do
        get(REQUEST_URI, query: query_params)['Records']
      end
      # Now query for single Coworker using Coworker.Id because it gives more info
      return nil unless results.try(:first)
      url = "#{REQUEST_URI}/#{results.first['Id']}"
      result = Rails.cache.fetch([url], expires: 12.hours) do
        get(url).parsed_response
      end
      new(result)
    end
  end

  def total_hours_in_plan
    extra_service['TotalUses'] / 60
  end

  def billing_plan
    url = "#{BILLING_PLANS_URI}/#{next_tariff_id}/"
    result = Rails.cache.fetch([url], expires: 24.hours) do
      self.class.get(url).parsed_response
    end
    result['Name']
  end

  def extra_service_cost_per_hour
    extra_service['Price'] / total_hours_in_plan
  end

  def remaining_plan_hours
    # Unfortunately, this only counts the bookings that have been charged, i.e. bookings already passed
    # See 'remaining_hours_in_plan' for actual total remaining hours
    query_params = { CoworkerExtraService_Coworker: id,
                     CoworkerExtraService_ExtraService_Name: 'Prep',
                     CoworkerExtraService_IsFromTariff: true }
    results = self.class.get(BILLING_URI, query: query_params)['Records']
    results.first['RemainingUses'] / 60
  end

  def remaining_hours_in_plan
    # Manually calculate how many hours are in upcoming "uncharged" bookings
    # Subtract them from the system's "remaining hours"
    bookings = Booking.all(coworker_id: id)
    upcoming_booking_hours = bookings.sum(&:duration_in_minutes) / 60
    remaining_plan_hours - upcoming_booking_hours
  end

  def extra_service
    query_params = { CoworkerExtraService_Coworker: id,
                     CoworkerExtraService_ExtraService_Name: 'Prep',
                     CoworkerExtraService_IsFromTariff: true }
    @_extra_service ||= Rails.cache.fetch([BILLING_URI, query_params], expires: 12.hours) do
      self.class.get(BILLING_URI, query: query_params)['Records']
    end.first
    # Do not cache empty extra service
    Rails.cache.delete([BILLING_URI, query_params]) unless @_extra_service
    @_extra_service
  end

  def maker?
    # Makers operate with Prep Tables and other users operate with Prep Stations
    extra_service['ExtraServiceName'] == 'Prep Table'
  end

  def can_book?(from, to)
    # Only makers can book on sunday from 8:00 AM to 6:00 PM
    return maker? if from.in_time_zone.sunday? && to.in_time_zone.sunday? &&
        to.in_time_zone.hour <= 18 && from.in_time_zone.hour >= 8
    !maker?
  end

  def to_s
    {name: full_name, maker: maker?, active: active}.to_json
  end
end

class Coworker < NexudusBase
  attr_accessor :id, :user_id, :email, :full_name, :salutation, :active, :next_tariff_id
  REQUEST_URI = '/spaces/coworkers'.freeze
  BILLING_URI = '/billing/coworkerextraservices'.freeze
  BILLING_PLANS_URI = '/billing/tariffs'.freeze
  RESOURCE_TYPES = { 
    chief: 'Prep Station',
    maker: 'Prep Table',
    admin: 'Prep Space',
    day_use: 'Prep Station'
  }.freeze
  ROLES = {
    chief: 'Chief',
    maker: 'Maker',
    admin: 'Admin',
    day_use: 'Day Use'
  }.freeze

  class << self
    def find_by_user(user_id, query = {})
      # Find by UserId since it's all we have so far
      query_params = { Coworker_User: user_id }.merge(query)
      results = Rails.cache.fetch([REQUEST_URI, query_params], expires: 24.hours, cache_nils: false) do
        get(REQUEST_URI, query: query_params)['Records']
      end
      # Now query for single Coworker using Coworker.Id because it gives more info
      return nil unless results.try(:first)
      url = "#{REQUEST_URI}/#{results.first['Id']}"
      result = Rails.cache.fetch([url], expires: 12.hours, cache_nils: false) do
        get(url).parsed_response
      end
      new(result)
    end

    def can_book?(role, from, to)
      from = from.in_time_zone
      to = to.in_time_zone
      return true if role == :admin
      # Makers can book only on sunday from 8:00 AM to 6:00 PM
      return from.sunday? && to.sunday? && from.hour >= 8 && (to.hour < 18 || (to.hour == 18 && to.min == 0)) if role == :maker
      true
    end
  end

  def total_hours_in_plan
    extra_service['TotalUses'] / 60
  end

  def billing_plan
    url = "#{BILLING_PLANS_URI}/#{next_tariff_id}/"
    result = Rails.cache.fetch([url], expires: 24.hours, cache_nils: false) do
      self.class.get(url).parsed_response
    end
    result['Name']
  end

  def extra_service_cost_per_hour
    extra_service['Price'] / total_hours_in_plan
  end

  def remaining_plan_hours
    query_params = { CoworkerExtraService_Coworker: id,
                     CoworkerExtraService_ExtraService_Name: 'Prep',
                     CoworkerExtraService_IsFromTariff: true }
    results = self.class.get(BILLING_URI, query: query_params)['Records']
    results.first['RemainingUses'] / 60
  end

  def remaining_hours_in_plan
    # Manually calculate how many hours are in upcoming "uncharged" bookings
    # Subtract them from the system's "remaining hours"
    bookings = Booking.upcoming_uncharged(id)
    # bookings.select { |b| b.from_time >= DateTime.now }.sum(&:duration_in_minutes)
    upcoming_booking_hours = bookings.sum(&:duration_in_minutes) / 60
    remaining_plan_hours - upcoming_booking_hours
  end

  def extra_service
    query_params = { CoworkerExtraService_Coworker: id,
                     CoworkerExtraService_ExtraService_Name: 'Prep',
                     CoworkerExtraService_IsFromTariff: true }
    @_extra_service ||= Rails.cache.fetch([BILLING_URI, query_params], expires: 12.hours, cache_nils: false) do
      self.class.get(BILLING_URI, query: query_params)['Records'].first
    end
    # Do not cache empty extra service
    Rails.cache.delete([BILLING_URI, query_params]) unless @_extra_service
    @_extra_service
  end

  def role
    ROLES.key(billing_plan)
  end

  def maker?
    role == :maker
  end

  def admin?
    role == :admin
  end

  def can_book?(from, to)
    Coworker.can_book?(role, from, to)
  end

  def to_s
    { name: full_name, role: role, active: active }.to_json
  end
end

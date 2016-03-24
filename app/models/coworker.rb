class Coworker < NexudusBase
  attr_accessor :id, :user_id, :email, :full_name, :salutation, :active, :next_tariff_id
  REQUEST_URI = "/spaces/coworkers"
  BILLING_URI = "/billing/coworkerextraservices"
  BILLING_PLANS_URI = "/billing/tariffs"

  def initialize(params)
    params.map do |k,v|
      attribute_name = k.underscore
      public_send("#{k.underscore}=", v) if respond_to?(attribute_name)
    end
  end

  def self.find_by_user(user_id, query = {})
    # Find by UserId since it's all we have so far
    query_params = {"Coworker_User" => user_id}.merge(query)
    results = Rails.cache.fetch([REQUEST_URI, query_params], :expires => 24.hours) do
      get(REQUEST_URI, :query => query_params)["Records"]
    end
    # Now query for single Coworker using Coworker.Id because it gives more info
    url = "#{REQUEST_URI}/#{results.first["Id"]}"
    result = Rails.cache.fetch([url], :expires => 12.hours) do
      get(url).parsed_response
    end
    #TODO - add error handling, e.g. if no record found
    new(result)
  end

  def total_hours_in_plan
    query_params = {"CoworkerExtraService_Coworker" => self.id, "CoworkerExtraService_ExtraService_Name" => "Prep Table", "CoworkerExtraService_IsFromTariff" => true}
    results = Rails.cache.fetch([BILLING_URI, query_params], :expires => 12.hours) do
      self.class.get(BILLING_URI, :query => query_params)["Records"]
    end
    results.first["TotalUses"]/60
  end

  def billing_plan
    url = "#{BILLING_PLANS_URI}/#{next_tariff_id}/"
    result = Rails.cache.fetch([url], :expires => 24.hours) do
      self.class.get(url).parsed_response
    end
    result["Name"]
  end

  def extra_service_cost_per_hour
    query_params = {"CoworkerExtraService_Coworker" => self.id, "CoworkerExtraService_ExtraService_Name" => "Prep Table", "CoworkerExtraService_IsFromTariff" => true}
    results = Rails.cache.fetch([BILLING_URI, query_params], :expires => 12.hours) do
      self.class.get(BILLING_URI, :query => query_params)["Records"]
    end
    results.first["Price"]/(total_hours_in_plan)
  end

  def remaining_uncharged_hours_in_plan
    # Unfortunately, this only counts the bookings that have been charged, i.e. bookings already passed
    # See 'remaining_hours_in_plan' for actual total remaining hours
    query_params = {"CoworkerExtraService_Coworker" => self.id, "CoworkerExtraService_ExtraService_Name" => "Prep Table", "CoworkerExtraService_IsFromTariff" => true}
    results = self.class.get(BILLING_URI, :query => query_params)["Records"]
    results.first["RemainingUses"]/60
  end

  def remaining_hours_in_plan
    # Manually calculate how many hours are in upcoming "uncharged" bookings
    # Subtract them from the system's "remaining hours"
    bookings = Booking.all(id)
    upcoming_booking_hours = bookings.sum(&:duration_in_minutes)/60
    remaining_uncharged_hours_in_plan - upcoming_booking_hours
  end

end
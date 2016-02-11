class Coworker < NexudusBase
  attr_accessor :id, :user_id, :email, :full_name, :salutation, :active
  @@request_uri = "/spaces/coworkers"
  @@billing_uri = "/billing/coworkerextraservices"

  def initialize(params)
    params.map do |k,v|
      attribute_name = k.underscore
      public_send("#{k.underscore}=", v) if respond_to?(attribute_name)
    end
  end

  def self.find_by_user(user_id, query = {})
    query_params = {"Coworker_User" => user_id}.merge(query)
    results = Rails.cache.fetch([@@request_uri,query_params], :expires => 12.hours) do
      get(@@request_uri, :query => query_params)["Records"]
    end
    #TODO - add error handling, e.g. if no record found
    coworker = new(results.first)
  end

  def total_hours_in_plan
    query_params = {"CoworkerExtraService_Coworker" => self.id, "CoworkerExtraService_ExtraService_Name" => "Prep Table", "CoworkerExtraService_IsFromTariff" => true}
    results = Rails.cache.fetch([@@billing_uri,query_params], :expires => 12.hours) do
      self.class.get(@@billing_uri, :query => query_params)["Records"]
    end
    return results.first["TotalUses"]/60
  end

  def remaining_uncharged_hours_in_plan
    # Unfortunately, this only counts the bookings that have been charged, i.e. bookings already passed
    # See 'remaining_hours_in_plan' for actual total remaining hours
    query_params = {"CoworkerExtraService_Coworker" => self.id, "CoworkerExtraService_ExtraService_Name" => "Prep Table", "CoworkerExtraService_IsFromTariff" => true}
    results = self.class.get(@@billing_uri, :query => query_params)["Records"]
    remaining_hours = results.first["RemainingUses"]/60
  end

  def remaining_hours_in_plan
    # Manually calculate how many hours are in upcoming "uncharged" bookings
    # Subtract them from the system's "remaining hours"
    bookings = Booking.all(id)
    upcoming_booking_hours = bookings.sum(&:duration_in_minutes)/60
    return remaining_uncharged_hours_in_plan - upcoming_booking_hours
  end

end
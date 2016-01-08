class Coworker < NexudusBase
  attr_accessor :id, :user_id, :email, :full_name, :salutation, :active
  @@request_uri = "/spaces/coworkers"

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

end
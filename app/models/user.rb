class User < NexudusBase
  attr_accessor :id, :email, :password, :full_name, :active
  @@request_uri = "/sys/users"

  def initialize(params)
    params.map do |k,v|
      attribute_name = k.underscore
      public_send("#{k.underscore}=", v) if respond_to?(attribute_name)
    end
  end

  def self.find(id)
    url = @@request_uri+"/#{id}"
    result = Rails.cache.fetch([url], :expires => 12.hours) do
      get(url).parsed_response
    end
    user = new(result)
  end

  def self.authenticate(email,password)
    result = post(@@request_uri+"/validate", :body => {:email => email, :password => password}.to_json, :headers => { 'Content-Type' => 'application/json' }).parsed_response
    if result["Status"] == 200
      return User.new({"Id" => result["Value"]["Id"], "Email" => result["Value"]["Email"], "Active" => result["Value"]["Active"]})
    else
      return result
    end
  end

end
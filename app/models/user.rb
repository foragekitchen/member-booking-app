class User < NexudusBase
  attr_accessor :id, :email, :password, :full_name, :active
  REQUEST_URI = '/sys/users'

  def initialize(params)
    params.map do |k, v|
      attribute_name = k.to_s.underscore
      public_send("#{attribute_name}=", v) if respond_to?(attribute_name)
    end
  end

  def self.authenticate(email, password)
    result = post("#{REQUEST_URI}/validate",
                  body: {email: email, password: password}.to_json,
                  headers: { 'Content-Type' => 'application/json' }).parsed_response
    return result unless result['Status'] == 200
    User.new({Id: result['Value']['Id'], Email: result['Value']['Email'], Active: result['Value']['Active']})
  end

end
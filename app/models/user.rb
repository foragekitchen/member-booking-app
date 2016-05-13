class User < NexudusBase
  attr_accessor :id, :email, :password, :full_name, :active
  REQUEST_URI = '/sys/users'.freeze

  class << self
    def authenticate(email, password)
      result = post("#{REQUEST_URI}/validate",
                    body: { email: email, password: password }.to_json,
                    headers: { 'Content-Type' => 'application/json' }).parsed_response
      return result unless result['Status'] == 200
      User.new(Id: result['Value']['Id'], Email: result['Value']['Email'], Active: result['Value']['Active'])
    end
  end
end

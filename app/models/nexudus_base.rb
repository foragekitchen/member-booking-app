class NexudusBase
  include HTTParty
  base_uri 'spaces.nexudus.com/api'
  basic_auth Rails.application.secrets.nexudus_username, Rails.application.secrets.nexudus_password
  # debug_output $stdout # <= will spit out all request details to the console

  class << self
    def get(*args)
      response = super
      puts "Nexudus: #{args.inspect} -- #{response.inspect}"
      return response if response.code < 300
      puts("Nexudus error response: #{response.inspect}")
      if response.code == 409
        sleep 0.5
        get(*args)
      end
    end
  end

  def initialize(params = {})
    params.map do |k, v|
      attribute_name = k.to_s.underscore
      public_send("#{attribute_name}=", v) if respond_to?(attribute_name)
    end
  end
end

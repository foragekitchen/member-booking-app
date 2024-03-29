class NexudusBase
  include HTTParty
  base_uri 'https://spaces.nexudus.com/api'
  basic_auth Rails.application.secrets.nexudus_username, Rails.application.secrets.nexudus_password
  # debug_output $stdout # <= will spit out all request details to the console

  class << self
    def get(*args)
      tries = 3
      begin
        if args.length == 1
          request_args = [args, format: :json].flatten
        else
          params = args[1]
          request_args = [args[0], params.merge(format: :json)]
        end
        response = super(*request_args)
        NexudusApp.log "Nexudus: #{request_args.inspect} -- #{response.inspect}"
        return response if response.code < 300
        NexudusApp.log("Nexudus error response: #{response.inspect}")
        if response.code == 409
          sleep 0.5
          get(*args)
        end
      rescue Net::OpenTimeout
        tries -= 1
        tries.zero? ? raise : retry
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

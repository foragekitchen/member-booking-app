if defined?(Rack::Timeout)
  Rack::Timeout.timeout = (ENV['RACK_TIMEOUT'] || (Rails.env.test? ? 0 : 20)).to_i
end
if defined?(Rack::Timeout)
  Rack::Timeout.timeout = (ENV['RACK_TIMEOUT'] || 20).to_i
end
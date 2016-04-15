require 'httparty'

class NexudusBase
  include HTTParty
  base_uri 'spaces.nexudus.com/api'
  basic_auth Rails.application.secrets.nexudus_username, Rails.application.secrets.nexudus_password
  # debug_output $stdout # <= will spit out all request details to the console

end
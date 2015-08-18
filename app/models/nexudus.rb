require 'httparty'

class Nexudus
  include HTTParty
  base_uri 'spaces.nexudus.com/api'

  def initialize()
    self.class.basic_auth Rails.application.secrets.nexudus_username, Rails.application.secrets.nexudus_password 
  end

  def resources(id=nil)
    self.class.get("/spaces/resources/#{id}")
  end

end
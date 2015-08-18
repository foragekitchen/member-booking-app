require 'httparty'

class Nexudus
  include HTTParty
  base_uri 'spaces.nexudus.com/api'

  def auth
    {:username => ENV['NEXUDUS_USERNAME'], :password => ENV['NEXUDUS_PASSWORD']}
  end

  def initialize()
    @options = { :basic_auth => auth }
  end

  def resources(id=nil)
    self.class.get("/spaces/resources/#{id}", @options)
  end

end
require 'httparty'

class NexudusBase
  include HTTParty
  base_uri 'spaces.nexudus.com/api'

  def initialize()
    self.class.basic_auth Rails.application.secrets.nexudus_username, Rails.application.secrets.nexudus_password 
  end

  def get(*args, &block)
    self.class.get(*args, &block)
  end

  def delete(*args, &block)
    self.class.delete(*args, &block)
  end

  def post(*args, &block)
    self.class.post(*args, &block)
  end

end
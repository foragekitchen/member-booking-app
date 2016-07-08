class BookingProduct < NexudusBase
  attr_accessor :id, :booking_id, :product_id
  PRODUCTS_URI = '/billing/products'.freeze
  REQUEST_URI = '/spaces/bookingproducts'.freeze

  class << self
    def find_by_booking_id(booking_id, query = {})
      query_params = { 'BookingProduct_Booking' => booking_id }.merge(query)
      results = Rails.cache.fetch([REQUEST_URI, query_params], expires: 24.hours) do
        get(REQUEST_URI, query: query_params)['Records']
      end
      return nil unless results.try(:first)
      booking_product = results.first
      # Nexudus respong with booking id `0`. Replace it with our booking id
      booking_product['BookingId'] = booking_id
      new(booking_product)
    end

    def find_invite_friend_plan
      query = { 'Product_Name' => 'Invite a friend' }
      Rails.cache.fetch([PRODUCTS_URI, query], expires: 1.month) do
        get(PRODUCTS_URI, query: query)['Records'].try(:first)
      end
    end

    # @todo: decide if we need this method
    def all
      Rails.cache.fetch(PRODUCTS_URI, expires: 1.week) do
        get(PRODUCTS_URI)['Records']
      end
    end
  end

  def create
    attrs = Hash[instance_variables.map! { |name| [name.to_s.gsub(/@/, '').classify, instance_variable_get(name)] }]
    self.class.post(REQUEST_URI, body: attrs.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end
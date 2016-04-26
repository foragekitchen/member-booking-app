class Resource < NexudusBase
  attr_accessor :id, :description, :linked_resources, :location, :name, :resource_type_name, :timeslots, :visible, :late_cancellation_limit, :available
  REQUEST_URI = '/spaces/resources'

  def initialize(params)
    params.each do |k, v|
      attribute_name = k.to_s.underscore
      public_send("#{attribute_name}=", v) if respond_to?(attribute_name)
    end
    load_available
    load_location
  end

  def prep_table?
    resource_type_name == 'Prep Table'
  end

  def location?
    resource_type_name == 'Resource Location'
  end

  private
  def load_available
    self.available ||= false
  end

  def load_location
    unless prep_table? && linked_resources.first && linked_resources.first != self.id && (linked_resource = Resource.find(linked_resources.first))
      self.location ||= [0, 0]
    else
      loc = linked_resource.description.include?('@') ? linked_resource.description.split('@').last.split(',') : nil
      self.location ||= loc ? loc.map!{ |ft| ResourceLocation.new.convert_from_feet_to_inches(ft) } : [0, 0]
    end
  end

  class << self
    def all(query = {})
      query.merge!({ Resource_ResourceType_Name: 'Prep Table', Resource_Visible: true })
      results = Rails.cache.fetch([REQUEST_URI, query], expires: 12.hours) do
        get(REQUEST_URI, query: query)['Records']
      end

      results.map{ |r| find(r['Id']) }
    end

    def find(id, predefined_params = {})
      url = "#{REQUEST_URI}/#{id}"
      result = Rails.cache.fetch([url], expires: 12.hours) do
        get(url).parsed_response
      end
      new(result.merge(predefined_params.merge('id' => id)))
    end

    def all_with_available(from_time = Time.current + 2.hours, to_time = Time.current + 6.hours)
      from_time = Time.parse(from_time) if from_time.is_a?(String)
      to_time = Time.parse(to_time) if to_time.is_a?(String)

      resources = all
      available = available_ids(from_time, to_time)

      bookings = Booking.all('', available)

      resources.each { |resource| resource.available = true if available.include?(resource.id) }

      bookings.each do |booking|
        next unless available.include?(booking.resource_id) && (resource = resources.select{ |r| r.id == booking.resource_id }.first)
        if booking.from_time >= from_time && booking.to_time <= to_time || # falls exactly inside the slot
           booking.from_time >= from_time && booking.from_time < to_time || # overlaps after requested start
           booking.from_time <= from_time && booking.to_time > from_time # overlaps before requested start
          resource.available = false
          available.delete(resource.id)
          next
        end
      end
      resources
    end

    private
    def available_ids(from_time = Time.current + 2.hours, to_time = Time.current + 6.hours)
      Timeslot.available(from_time, to_time).collect{|t| t['ResourceId']}.uniq
    end

  end
end
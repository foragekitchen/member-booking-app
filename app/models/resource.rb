class Resource < NexudusBase
  attr_accessor :id, :description, :linked_resources, :location, :name, :resource_type_name, :timeslots, :visible, :late_cancellation_limit, :available
  REQUEST_URI = '/spaces/resources'

  def initialize(params)
    params.map do |k, v|
      attribute_name = k.to_s.underscore
      public_send("#{attribute_name}=", v) if respond_to?(attribute_name)
    end
    self.available = false
  end

  def self.all(location = true, query = {})
    query_params = {Resource_ResourceType_Name: 'Prep Table', Resource_Visible: true}.merge(query)
    results = Rails.cache.fetch([REQUEST_URI, query_params], :expires => 12.hours) do
      get(REQUEST_URI, :query => query_params)['Records']
    end
    resources = []

    results.each do |r|
      next unless r['ResourceTypeName'] == query_params[:Resource_ResourceType_Name]

      resource_with_details = find(r['Id'])
      resource_with_details.id = r['Id'] #TODO - find better way for rspec; this is purely to help with rspec because every single-resource returns same id
      if location && resource_with_details.linked_resources.present?
        resource_with_details.location = get_location_of_linked(resource_with_details.linked_resources.first)
      end

      resources << resource_with_details
    end
    resources
  end

  def self.available_ids(from_time = Time.now + 2.hours, to_time = Time.now + 6.hours)
    Timeslot.available(from_time, to_time).collect{|t| t['ResourceId']}.uniq
  end

  def self.booked_ids(from_time = Time.now + 2.hours, to_time = Time.now + 6.hours, resource_ids=[])
    from_time = Time.parse(from_time) if from_time.is_a?(String) #just in case; this should already be in correct Time format
    to_time = Time.parse(to_time) if to_time.is_a?(String) #just in case; this should already be in correct Time format
    from_time.utc
    to_time.utc

    results = Booking.all('', resource_ids)
    set = resource_ids

    results.each do |booking|
      next unless set.include? booking.resource_id
      set.delete(booking.resource_id) if booking.from_time >= from_time && booking.to_time <= to_time # falls exactly inside the slot
      set.delete(booking.resource_id) if booking.from_time >= from_time && booking.from_time < to_time # overlaps after requested start
      set.delete(booking.resource_id) if booking.from_time <= from_time && booking.to_time > from_time # overlaps before requested start
    end
    set.map do |resource_id|
      resource = find(resource_id)
      resource.available = true
      resource.location = get_location_of_linked(resource.linked_resources.first)
      resource
    end
  end

  def self.find(id)
    url = "#{REQUEST_URI}/#{id}"
    result = Rails.cache.fetch([url], :expires => 12.hours) do
      get(url).parsed_response
    end
    new(result)
  end

  def self.get_location_of_linked(id)
    linked = find(id)
    location = nil
    if linked.present?
      location = linked.description.include?('@') ? linked.description.split('@').last.split(',') : nil
      location.map!{ |ft| ResourceLocation.new.convert_from_feet_to_inches(ft) } if location.is_a?(Array)
    end
    location
  end

end
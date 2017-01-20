class Resource < NexudusBase
  attr_accessor :id, :description, :linked_resources, :location, :name,
                :resource_type_name, :timeslots, :visible, :available, :group_name
  attr_writer :late_cancellation_limit
  REQUEST_URI = '/spaces/resources'.freeze

  def initialize(params)
    super
    load_available
    load_location
  end

  def late_cancellation_limit
    # Set default cancellation limit to 24h in minutes
    @late_cancellation_limit || (24.hours / 60)
  end

  def prep_resource?
    Coworker::RESOURCE_TYPES.values.include? resource_type_name
  end

  private

  def load_available
    self.available ||= false
  end

  def load_location
    if prep_resource? && linked_resources.first && linked_resources.first != id &&
        (linked_resource = Resource.find(linked_resources.first))
      self.location = linked_resource.description.match(/(\d+):(\d+)/) ? [$1, $2] : [0, 0]
    else
      self.location ||= [0, 0]
    end
  end

  class << self
    def all(query = {}, role: :chief)
      resource_name = Coworker::RESOURCE_TYPES[role]
      query = query.merge(Resource_ResourceType_Name: resource_name, Resource_Visible: true)
      results = Rails.cache.fetch([REQUEST_URI, query], expires: 12.hours) do
        get(REQUEST_URI, query: query)['Records']
      end

      results.map { |r| find(r['Id']) }
    end

    def find(id, options = {})
      url = "#{REQUEST_URI}/#{id}"
      result = Rails.cache.fetch([url], expires: 12.hours) do
        get(url).parsed_response
      end
      new(result.merge(options.merge(id: id)))
    end

    def all_with_available(from_time: Time.current + 2.hours, to_time: Time.current + 4.hours, role: :chief)
      from_time = Time.parse(from_time) if from_time.is_a?(String)
      to_time = Time.parse(to_time) if to_time.is_a?(String)

      time_boundaries = { from_time: from_time, to_time: to_time }
      available = available_ids(time_boundaries)

      resources = all(role: role)
      other_resources =
        if role == :admin
          available = Timeslot.all_by_day(from_time.wday).map { |t| t['ResourceId'] }.uniq
          all(role: :maker) + all(role: :chief)
        else
          all(role: :admin)
        end
      bookings = Booking.all(resource_ids: available, options: time_boundaries.clone)

      other_resources.each { |resource| resource.available = true }
      resources.each { |resource| resource.available = true if available.include?(resource.id) }

      groups = []
      # @todo: get rid of this hardcoded value
      if role != :admin && from_time.wday == 0
        group_resources = all(role: role == :chief ? :maker : :chief)
        groups = booked_groups(group_resources, available, bookings, time_boundaries)
      end

      proceed_available!(other_resources, available, bookings, time_boundaries)
      if other_resources.all? { |resource| resource.available }
        proceed_available!(resources, available, bookings, time_boundaries, groups)
      else
        resources.each { |resource| resource.available = false }
      end

      resources
    end

    private

    def proceed_available!(resources, available, bookings, time_boundaries, booked_groups = [])
      for_booked_resources(resources, available, bookings, time_boundaries) do |resource|
        resource.available = false
        available.delete(resource.id)
      end
      resources.each { |r| r.available = false if booked_groups.include?(r.group_name) } if booked_groups.any?
    end

    def booked_groups(resources, available, bookings, time_boundaries)
      groups = []
      for_booked_resources(resources, available, bookings, time_boundaries) do |resource|
        groups << resource.group_name
      end
      groups.uniq
    end

    def for_booked_resources(resources, available, bookings, time_boundaries)
      bookings.each do |booking|
        next unless available.include?(booking.resource_id) && (resource = resources.select { |r| r.id == booking.resource_id }.first)
        if booking.from_time >= time_boundaries[:from_time] && booking.to_time <= time_boundaries[:to_time] || # falls exactly inside the slot
          booking.from_time >= time_boundaries[:from_time] && booking.from_time < time_boundaries[:to_time] || # overlaps after requested start
          booking.from_time <= time_boundaries[:from_time] && booking.to_time > time_boundaries[:from_time]    # overlaps before requested start
          yield(resource) if block_given?
        end
      end
    end

    def available_ids(from_time: Time.current + 2.hours, to_time: Time.current + 4.hours)
      Timeslot.available(from_time: from_time, to_time: to_time).map { |t| t['ResourceId'] }.uniq
    end
  end
end

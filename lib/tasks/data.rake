namespace :data do
  namespace :resourcetimeslots do
    desc 'Delete existing resource timeslots for \'Prep Table\', and repopulate.'
    task repopulate: :environment do

      n = NexudusBase.new
      timeslots = n.class.get('/spaces/resourcetimeslots?size=100')['Records']
      puts "Deleting #{timeslots.size} timeslot records.."
      timeslots.each { |t| n.class.delete("/spaces/resourcetimeslots/#{t['Id']}") }

        puts 'Now creating clean timeslot record(s)...'
      count = 0
      resources = Resource.all
      resources.each do |r|
        (0..6).each do |d|
          new_night_slot = {
            ResourceId: r.id,
            DayOfWeek: d,
            FromTime: Time.parse('1976-01-01T0:00:00').utc,
            ToTime: Time.parse('1976-01-01T2:00:00').utc
          }
          new_day_slot = {
            ResourceId: r.id,
            DayOfWeek: d,
            FromTime: Time.parse('1976-01-01T8:00:00').utc,
              ToTime: Time.parse('1976-01-01T23:59:59').utc
          }
          n.class.post('/spaces/resourcetimeslots',
            body: new_night_slot.to_json,
            headers: { 'Content-Type' => 'application/json' })
          count += 1
          n.class.post('/spaces/resourcetimeslots',
            body: new_day_slot.to_json,
            headers: { 'Content-Type' => 'application/json' })
          count += 1
        end
      end

      puts "Created #{count} timeslot record(s)"
    end
  end

  namespace :bookings do
    desc 'Delete all upcoming bookings - USE WITH CAUTION AND ONLY WHEN TESTING'
    task delete_upcoming: :environment do
      bookings = Booking.all
      bookings.reject { |b| b.from_time.to_time < Time.now.utc }.each(&:destroy)
    end

    desc 'Delete all bookings - USE WITH CAUTION AND ONLY WHEN TESTING'
    task delete_all: :environment do
      bookings = Booking.all
      bookings.each(&:destroy)
    end
  end
end

namespace :data do
  namespace :resourcetimeslots do
    desc "Delete existing resource timeslots for 'Prep Table', and repopulate."
    task :repopulate => :environment do

      n = NexudusBase.new
      timeslots = n.get("/spaces/resourcetimeslots")["Records"]
      puts "Deleting #{timeslots.size} timeslot records.."
      timeslots.each do |t|
        n.delete("/spaces/resourcetimeslots/#{t["Id"]}")
      end
      
      puts "Now creating clean timeslot record(s)..."
      count = 0
      resources = Space.new.resources
      resources.each do |r|
        (1..7).each do |d|
          newNightSlot = {
            "ResourceId" => r[:id],
            "DayOfWeek" => d,
            "FromTime" => DateTime.parse("1976-01-01T0:00:00PST").utc,
            "ToTime": DateTime.parse("1976-01-01T2:00:00PST").utc
          }
          newDaySlot = {
            "ResourceId" => r[:id],
            "DayOfWeek" => d,
            "FromTime" => DateTime.parse("1976-01-01T8:00:00PST").utc,
            "ToTime": DateTime.parse("1976-01-01T23:59:59PST").utc
          }
          n.post("/spaces/resourcetimeslots", 
            :body => newNightSlot.to_json,
            :headers => { 'Content-Type' => 'application/json' })
          count += 1
          n.post("/spaces/resourcetimeslots", 
            :body => newDaySlot.to_json,
            :headers => { 'Content-Type' => 'application/json' })
          count += 1
        end
      end
      
      puts "Created #{count} timeslot record(s)"
      
    end
  end
end

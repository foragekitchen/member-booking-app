class FakeNexudus

  def self.call(env)

    case env["PATH_INFO"]
    when /spaces\/bookings\/\d/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/booking.json")]]
    when /spaces\/bookings/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/bookings.json")]]
    when /spaces\/resources\/\d/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/resource.json")]]
    when /spaces\/resources/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/resources.json")]]
    when /spaces\/resourcetimeslots/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/resourcetimeslots.json")]]
    when /spaces\/coworkers/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/coworkers.json")]]
    when /sys\/users\/validate/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/user.json")]]
    when /sys\/users\/\d/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/user.json")]]
    when /billing\/coworkerextraservices/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/coworkerextraservices.json")]]
    when /billing\/tariffs/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/tariff.json")]]
    else
      [404,{},[]]
    end

  end

end
class FakeNexudus

  def self.call(env)

    case env["PATH_INFO"]
    when /spaces\/bookings/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/bookings.json")]]
    when /spaces\/resources\/\d/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/resource.json")]]
    when /spaces\/resources/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/resources.json")]]
    when /spaces\/resourcetimeslots/
      [200, { 'Content-Type' => 'application/json' }, [File.read("spec/fixtures/resourcetimeslots.json")]]
    else
      [404,{},[]]
    end

  end

end
class FakeNexudus
  def self.call(env)
    case env['PATH_INFO']
    when %r{spaces/bookings/\d}
      [200, { 'Content-Type' => 'application/json' }, [File.read('spec/fixtures/booking.json')]]
    when %r{spaces/bookings}
      [200, { 'Content-Type' => 'application/json' }, [File.read('spec/fixtures/bookings.json')]]
    when %r{spaces/resources/(\d+)}
      [200, { 'Content-Type' => 'application/json' }, [
          File.read("spec/fixtures/resource_#{File.exists?("spec/fixtures/resource_#{$1}.json") ? $1 : 100}.json")
      ]]
    when %r{spaces/resources}
      if env['QUERY_STRING'].match(/Resource_ResourceType_Name=Prep%20Station/)
        [200, { 'Content-Type' => 'application/json' }, [File.read('spec/fixtures/resources.json')]]
      else
        [200, { 'Content-Type' => 'application/json' }, [File.read('spec/fixtures/admin_resources.json')]]
      end
    when %r{spaces/resourcetimeslots}
      [200, { 'Content-Type' => 'application/json' }, [File.read('spec/fixtures/resourcetimeslots.json')]]
    when %r{spaces/coworkers}
      [200, { 'Content-Type' => 'application/json' }, [File.read('spec/fixtures/coworkers.json')]]
    when %r{sys/users/validate}
      [200, { 'Content-Type' => 'application/json' }, [File.read('spec/fixtures/user.json')]]
    when %r{sys/users/\d}
      [200, { 'Content-Type' => 'application/json' }, [File.read('spec/fixtures/user.json')]]
    when %r{billing/coworkerextraservices}
      [200, { 'Content-Type' => 'application/json' }, [File.read('spec/fixtures/coworkerextraservices.json')]]
    when %r{billing/tariffs}
      [200, { 'Content-Type' => 'application/json' }, [File.read('spec/fixtures/tariff.json')]]
    else
      [404, {}, []]
    end
  end
end

require 'rails_helper'

RSpec.describe Resource, type: :model do
  before(:each) do
    @resources = Resource.all
  end

  describe "Resources for booking" do

    it "returns an array of one or more bookable resources" do
      expect( @resources.is_a?(Array) ).to eq true
    end

    it "includes only the type(s) of resources we want to be bookable, which is 'Prep Table'" do
      expect(@resources.collect(&:resource_type_name).uniq).to eq ["Prep Table"]
    end

    it "returns id, name, type, description, and location for each resource" do
      expect(@resources.first.instance_variables).to match_array [:@id, :@name, :@resource_type_name, :@description, :@location, :@visible, :@linked_resources]
    end

    describe "that are available" do

      it "only includes resources that are offered during the requested timeframe" do
        available = Resource.available_ids("2015-09-01T12:00:00PST","2015-09-01T16:00:00PST")
        expect(available).to eq [100,101]
      end

      it "returns empty set if nothing is offered during the requested timeframe" do
        available = Resource.available_ids("2015-09-01T02:00:00PST","2015-09-01T04:00:00PST")
        expect(available).to eq []
      end

      it "only includes resources that are not already booked, i.e. falls exactly inside the requested time" do
        # Requesting 2-6PM on 9/1 but already booked 8AM-12PM and 1PM-7PM
        available = Resource.booked_ids("2015-09-01T14:00:00PST","2015-09-01T18:00:00PST",[100,101,102])
        expect(available).to eq [101,102]
      end

      it "only includes resources that are not already booked, i.e. booked before the requested start time but overlaps" do
        # Requesting 10AM-2PM on 9/2 but already booked 8AM-12PM
        available = Resource.booked_ids("2015-09-02T10:00:00PST","2015-09-02T14:00:00PST",[100,101,102])
        expect(available).to eq [100,102]
      end

      it "only includes resources that are not already booked, i.e. booked after the requested start time but overlaps" do
        # Requesting 8PM-Midnight on 9/3 but already booked 10PM-2AM
        available = Resource.booked_ids("2015-09-03T20:00:00PST","2015-09-04T00:00:00PST",[100,101,102])
        expect(available).to eq [100,101]
      end


      it "returns empty set if all resources are already booked during the requested timeframe" do
        # Requesting 10AM-2PM on 9/1 but already booked 8AM-12PM and 1PM-7PM
        available = Resource.booked_ids("2015-09-01T10:00:00PST","2015-09-01T14:00:00PST",[100,104])
        expect(available).to eq []
      end

    end

  end
end

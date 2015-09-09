require 'rails_helper'

RSpec.describe Space, "(e.g. Kitchen Space):", type: :model do
  before(:each) do
    @resources = Space.new.resources
  end

  describe "Resources for booking" do

    it "returns an array of one or more bookable resources" do
      expect( @resources.is_a?(Array) ).to eq true
    end

    it "includes only the type(s) of resources we want to be bookable, which is 'Prep Table'" do
      expect(@resources.collect{|r| r[:type] }.uniq).to eq ["Prep Table"]
    end

    it "returns id, name, type, description, and location for each resource" do
      expect(@resources.first.keys).to match_array [:id, :name, :type, :description, :location]
    end

    describe "that are available" do

      it "only includes resources that are offered during the requested timeframe" do
        available = Space.new.available_resources_by_day_and_time(2,"12:00:00","16:00:00")
        expect(available).to eq [101]
      end

      it "returns empty set if nothing is offered during the requested timeframe" do
        available = Space.new.available_resources_by_day_and_time(2,"2:00:00","4:00:00")
        expect(available).to eq []
      end

      it "only includes resources that are not already booked, i.e. falls exactly inside the requested time" do
        # Requesting 2-6PM on 9/1 but already booked 8AM-12PM and 1PM-7PM
        available = Space.new.booked_resources_by_datetime([100,101,102],"2015-09-01T14:00:00PST","2015-09-01T18:00:00PST")
        expect(available).to eq [101,102]
      end

      it "only includes resources that are not already booked, i.e. booked before the requested start time but overlaps" do
        # Requesting 10AM-2PM on 9/2 but already booked 8AM-12PM
        available = Space.new.booked_resources_by_datetime([100,101,102],"2015-09-02T10:00:00PST","2015-09-02T14:00:00PST")
        expect(available).to eq [100,102]
      end

      it "only includes resources that are not already booked, i.e. booked after the requested start time but overlaps" do
        # Requesting 8PM-Midnight on 9/3 but already booked 10PM-2AM
        available = Space.new.booked_resources_by_datetime([100,101,102],"2015-09-03T20:00:00PST","2015-09-04T00:00:00PST")
        expect(available).to eq [100,101]
      end


      it "returns empty set if all resources are already booked during the requested timeframe" do
        # Requesting 10AM-2PM on 9/1 but already booked 8AM-12PM and 1PM-7PM
        available = Space.new.booked_resources_by_datetime([100,104],"2015-09-01T10:00:00PST","2015-09-01T14:00:00PST")
        expect(available).to eq []
      end

    end

  end
end

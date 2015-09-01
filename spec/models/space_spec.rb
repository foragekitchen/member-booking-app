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
        available = Space.new.available_resources_by_day_and_time(2,"13:00:00","17:00:00")
        expect(available).to eq [101]
      end

      it "returns empty set if nothing is offered during the requested timeframe" do
        available = Space.new.available_resources_by_day_and_time(2,"2:00:00","4:00:00")
        expect(available).to eq []
      end

      pending "only includes resources that are not already booked during the requested timeframe"
      pending "returns empty set if all resources are already booked during the requested timeframe"

    end

  end
end

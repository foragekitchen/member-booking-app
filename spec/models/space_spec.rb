require 'rails_helper'

RSpec.describe Space, "(e.g. Kitchen Space):", type: :model do
  before(:all) do
    @resources = Space.new.resources
  end

  describe "Resources for booking" do

    it "returns an array of one or more bookable resources" do
      expect( @resources.is_a?(Array) ).to eq true
    end

    it "includes only the type(s) of resources we want to be bookable, which is 'Prep Table'" do
      expect(@resources.collect{|r| r[:type] }.uniq).to eq ["Prep Table"]
    end

    it "returns id, name, type, description, timeslots, and location for each resource" do
      expect(@resources.first.keys).to match_array [:id, :name, :type, :description, :location, :time_slots]
    end

  end
end

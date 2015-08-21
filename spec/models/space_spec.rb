require 'rails_helper'

RSpec.describe Space, type: :model do
  before(:all) do
    @resources = Space.new.resources
  end

  describe "Resources for booking" do

    it "returns an array of one or more items" do
      expect( @resources.is_a?(Array) ).to eq true
    end

    it "includes only Prep Tables" do
      expect(@resources.collect{|r| r[:type] }.uniq).to eq ["Prep Tables"]
    end

    it "returns id, name, type, and location for each resource" do
      expect(@resources.first.keys).to match_array [:id, :name, :type, :location]
    end

  end
end

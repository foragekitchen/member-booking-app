require 'rails_helper'

RSpec.describe Space, type: :model do
  before(:all) do
    @resources = Space.new.resources
  end

  describe "Resources for booking" do

    it "returns an array of one or more items" do
      expect( @resources.is_a?(Array) ).to eq true
    end

    pending "includes only Cooking Blocks" 

    it "returns id, name, and location for each resource" do
      expect(@resources.first.keys).to match_array [:id, :name, :location]
    end

  end
end

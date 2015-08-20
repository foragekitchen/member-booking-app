require 'rails_helper'

RSpec.describe ResourceLocation, type: :model do

  it "should convert feet to inches (this more atomic measurement is easier to work with)" do
    str = "5'3\""
    expect( ResourceLocation.new.convert_from_feet_to_inches(str) ).to eq 63
  end

end

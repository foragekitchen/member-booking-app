# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ResourceLocation, type: :model do
  it 'should convert feet to inches (this more atomic measurement is easier to work with when plotting things onto a map); expects each resource to have a linked \'Resource Location\' with coordinate entered like this: \' @5\'2",4\' \' into the description' do
    expect(ResourceLocation.new.convert_from_feet_to_inches("5'3\"")).to eq 63
  end
end

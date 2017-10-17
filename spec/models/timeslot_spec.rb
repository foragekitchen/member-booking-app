# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Timeslot, type: :model do
  describe 'Caching' do
    it 'should be turned on for fetching Timeslots by day' do
      Rails.cache.clear
      rails_caching = double.as_null_object
      allow(Rails).to receive(:cache).and_return(rails_caching)
      expect(rails_caching).to receive(:fetch).with(['/spaces/resourcetimeslots',
                                                     { ResourceTimeSlot_DayOfWeek: 2, size: 100 }],
                                                    expires: 12.hours, cache_nils: true)
      Timeslot.all_by_day(2)
    end
  end
end

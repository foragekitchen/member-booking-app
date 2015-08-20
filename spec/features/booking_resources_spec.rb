require 'rails_helper'

RSpec.feature "Booking Resources:", type: :feature do

  scenario "Member visiting Booking page should see resources plotted on a map of the space", js: true do
    visit "/bookings"
    expect(page).to have_css("#map-container div.resource", wait: 10)
  end

end

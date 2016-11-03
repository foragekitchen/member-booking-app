class RSpec::Core::ExampleGroup
  def available_start_time(time, maker = false)
    time += 1.day if time.sunday? && !maker
    time.change(hour: 11).utc + Time.now.utc_offset
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def wait_for_selector(selector, params = {})
    50.times do
      sleep 0.1
      break if first(selector, params)
    end
  end

  def create_booking(start_time)
    # Create a real booking - useful for doing before testing anything else
    visit '/resources'

    day = start_time.to_s(:booking_day)
    from = start_time.beginning_of_hour
    to = (from + 4.hours).to_s(:booking_time)
    from = from.to_s(:booking_time)
    # update the filters form
    set_time_range('#filter-time-slider', from, to)
    fill_in('bookingRequestDate', with: day)

    wait_for_ajax
    page.first('.resource.available', wait: 10).click
    # Remember some stuff so we can find this booking later
    booking = {
      resource_name: page.find('.modal-title span', wait: 10).text,
      start_time: from.strip,
      end_time: to.strip
    }
    click_button('Save your booking')
    wait_for_url_to_have('#recurring-container')

    booking
  end

  def wait_for_url_to_have(string)
    50.times do
      sleep 0.1
      break if current_url.include?(string)
    end
  end

  def set_time_range(selector, from, to)
    from = Time.parse("1970-01-01 #{from}")
    to = Time.parse("1970-01-01 #{to}")
    values = [(from.hour - 8) * 60 + from.min, (to.hour + (to < from ? 24 : 0) - 8) * 60 + to.min]
    page.evaluate_script("$('#{selector}').slider('option', 'values', #{values.inspect})")
    page.evaluate_script("$('#{selector}').trigger('slide', true)")
  end

  def clear_bookings
    `rake data:bookings:delete_all`
  end

  private

  def finished_all_ajax_requests?
    # page.evaluate_script('jQuery.active').zero?
    page.evaluate_script('$.active > 0')
  end
end

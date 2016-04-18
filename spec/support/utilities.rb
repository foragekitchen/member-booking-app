class RSpec::Core::ExampleGroup
  def available_start_time(time)
    res = time.to_time.in_time_zone('Pacific Time (US & Canada)')
    res = res.change(hour: 11, min: res.min)
    res - res.utc_offset
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def wait_for_selector(selector, params = {})
    50.times do
      sleep 0.1
      break if find(selector, params)
    end
  end

  def create_booking(start_time = nil)
    # Create a real booking - useful for doing before testing anything else
    visit "/resources"
    if start_time.present? && start_time.is_a?(Time)
      # derive different date parts from the startTime
      day = start_time.to_s(:booking_day)
      from = start_time.beginning_of_hour
      to = (from + 4.hours).to_s(:booking_time)
      from = from.to_s(:booking_time)
      # update the filters form
      fill_in('When do you want to come in?', with: day)
      select_from_chosen(from, from: "bookingRequestFromTime")
      select_from_chosen(to, from: "bookingRequestToTime")
      click_button("Refresh")
    end
    # wait_for_ajax
    page.first("div.available div.button", wait: 10).click
    # Remember some stuff so we can find this booking later
    booking = {
        resource_name: page.find(".modal-title span", wait: 10).text,
        end_time: page.find(".modal-body h5 span", wait: 10).text.split(' to ').last
    }
    booking[:end_time] = booking[:end_time].strip if booking[:end_time].length > 8
    click_button("Save your booking")
    wait_for_url_to_have('#recurring-container')

    booking
  end

  def wait_for_url_to_have(string)
    50.times do
      sleep 0.1
      break if current_url.include?(string)
    end
  end

  private

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end
jQuery ->
  window.map_display = new MapDisplay
  window.booking_filter = new BookingFilter

  window.booking_filter.submit()

  $('#booking-filter input').trigger('change')

  $('#map-container').on 'click', '.button.available', (e) ->
    new BookingModal($(@).parent())
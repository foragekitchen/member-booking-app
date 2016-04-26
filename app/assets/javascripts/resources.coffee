jQuery ->
  window.map_display = new MapDisplay
  window.booking_filter = new BookingFilter

  $('#booking-filter input').trigger('change')

  window.booking_filter.submit()

  $('#map-container').on 'click', '.resource.available', (e) ->
    new BookingModal($(@))
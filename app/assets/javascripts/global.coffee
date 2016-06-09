jQuery ->
  $('.collapse').collapse()
  $('.datepicker').datepicker({
    minDate: currentTime().startOf('day').toDate()
    onSelect: ->
      window.booking_filter.submit() if window.booking_filter
  })
  $('[data-toggle="tooltip"]').tooltip()
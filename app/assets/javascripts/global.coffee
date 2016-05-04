jQuery ->
  $('.collapse').collapse()
  $('.datepicker').datepicker({onSelect: ->
    window.booking_filter.submit() if window.booking_filter
  })
  $('[data-toggle="tooltip"]').tooltip()
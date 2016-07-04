jQuery ->
  $('.collapse').collapse()
  user = getCurrentUser()
  $('.datepicker').datepicker({
    startDate: currentTime().startOf('day').toDate()
    daysOfWeekDisabled: if user && user.maker then [1, 2, 3, 4, 5, 6] else [0]
  }).on('changeDate', ->
    $(@).datepicker('hide')
    window.booking_filter.submit() if window.booking_filter
  )
  $('[data-toggle="tooltip"]').tooltip()
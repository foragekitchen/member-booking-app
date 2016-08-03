jQuery ->
  $('.collapse').collapse()
  user = getCurrentUser()
  # User can book up to 3 weeks
  datepickerOpts = {
    startDate: currentTime().startOf('day').toDate()
    endDate: moment(new Date).add(20, 'days').startOf('day').toDate()
    daysOfWeekDisabled: if user && user.maker then [1, 2, 3, 4, 5, 6] else [0]
  }
  $('.datepicker').datepicker($.extend({autoclose: true}, datepickerOpts)).on('changeDate', ->
    window.booking_filter.submit() if window.booking_filter
  )
  $('.multi-datepicker').datepicker($.extend({multidate: true}, datepickerOpts)).on('changeDate', (e) ->
    # Format all dates and store them indide of input value
    dates = []
    $.each(e.dates, (i, d) ->
      dates.push(e.format(i))
    )
    $("[name='#{$(@).attr('for')}']").val(dates.join(';'))
  )
  $('[data-toggle="tooltip"]').tooltip()
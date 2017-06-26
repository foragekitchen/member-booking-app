jQuery ->
  $('#booking-filter input').bookingFilterTime()

$.fn.bookingFilterTime = ->
  @each ->
    $(@).on 'change', ->
      return unless window.booking_filter
      timesState = window.booking_filter.timesState()
      dateFrom = window.booking_filter.datetimeFrom()
      dateTo = window.booking_filter.datetimeTo()
      dateTo = dateTo.add(1, 'day') if timesState.plus_day
      user = getCurrentUser()
      if user.role == 'maker' && (dateFrom.isoWeekday() != 7 || dateTo.isoWeekday() != 7 || dateTo.hours() > 18 || dateFrom.hours() < 8 || (dateTo.hours() == 18 && dateTo.minutes() > 0))
        $(document).trigger('map:loading:change', [on, 'Makers can only book on Sunday 8:00 AM - 6:00 PM'])
      else if dateFrom.isBefore(currentTime())
        $(document).trigger('map:loading:change', [on, 'Booking cannot be in the past.'])
      else if timesState.total < 1
        $(document).trigger('map:loading:change', [on, 'Booking must be at least 1 hours.'])
      else if timesState.total > 12
        $(document).trigger('map:loading:change', [on, 'Booking cannot be more than 12 hours.'])
      else
        $(document).trigger('map:loading:change', off)

jQuery ->
  $('#booking-filter select, #booking-filter input').bookingFilterTime()

$.fn.bookingFilterTime = ->
  @each ->
    $(@).on 'change', ->
      return unless window.booking_filter
      timesState = window.booking_filter.timesState()
      dateFrom = window.booking_filter.datetimeFrom()
      dateFrom = dateFrom.add(1, 'day') if timesState.plus_day
      if dateFrom.isBefore(moment(new Date()))
        $(document).trigger('map:loading:change', [on, 'Booking cannot be in the past.'])
      else if timesState.total < 4
        $(document).trigger('map:loading:change', [on, 'Booking must be at least 4 hours.'])
      else if timesState.total > 12
        $(document).trigger('map:loading:change', [on, 'Booking cannot be more than 12 hours.'])
      else
        $(document).trigger('map:loading:change', off)


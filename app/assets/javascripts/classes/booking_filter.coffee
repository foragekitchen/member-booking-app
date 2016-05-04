class window.BookingFilter
  xhrPool = []
  constructor: ->
    @holder = $('#booking-filter')

    @holder.on 'ajax:beforeSend', (e, jqXHR, options) ->
      xhrPool.push(jqXHR)

    @holder.on 'ajax:complete', (e, jqXHR, options) ->
      xhrPool = $.grep xhrPool, (x) ->
        x != jqXHR

    @holder.on 'ajax:success', ->
      $(document).trigger('map:loading:change', off)

    @holder.on 'ajax:send', ->
      $(document).trigger('map:loading:change', on)

  submit: ->
    return false unless @isValid()
    $.each xhrPool, (idx, jqXHR) ->
      jqXHR.abort()
    @holder.submit()

  isValid: ->
    return true unless $('#booking-filter-date').length
    timesState = @.timesState()
    dateFrom = @.datetimeFrom()
    dateFrom = dateFrom.add(1, 'day') if timesState.plus_day
    !(dateFrom.isBefore(currentTime()) || timesState.total < 4 || timesState.total > 12)

  timesState: ->
    date = @holder.find('#booking-filter-date').val()
    fromTime = @holder.find('#bookingRequestFromTime').val()
    toTime = @holder.find('#bookingRequestToTime').val()
    fromDateTime = formatFullDate(fromTime.trim())
    toDateTime = formatFullDate(toTime.trim())
    plusDay = toDateTime <= fromDateTime
    toDateTime = formatFullDate(toTime.trim(), '01/02/1970') if plusDay
    hours = moment.duration(toDateTime.diff(fromDateTime)).asHours()
    {date: date, from: fromTime, to: toTime, total: hours, plus_day: plusDay}

  datetimeFrom: ->
    formatFullDate(@holder.find('#bookingRequestFromTime').val(), @holder.find('#booking-filter-date').val())

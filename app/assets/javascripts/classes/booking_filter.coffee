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
      $('#map-container').removeClass('loading')
      $(document).trigger('map:loading:change', off)

    @holder.on 'ajax:send', ->
      $('#map-container').addClass('loading')
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
    dateTo = @.datetimeTo()
    if timesState.plus_day
      dateFrom = dateFrom.add(1, 'day')
      dateTo = dateTo.add(1, 'day')
    user = getCurrentUser()
    !(dateFrom.isBefore(currentTime()) || timesState.total < 4 || timesState.total > 12 ||
      (!user.maker && dateFrom.isoWeekday() == 7 && dateFrom.hours() < 20) ||
      (user.maker && (dateFrom.isoWeekday() != 7 || dateTo.hours() > 18 || (dateTo.hours() == 18 && dateTo.minutes() > 0))))

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

  datetimeTo: ->
    formatFullDate(@holder.find('#bookingRequestToTime').val(), @holder.find('#booking-filter-date').val())

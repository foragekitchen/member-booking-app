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
    $.each xhrPool, (idx, jqXHR) ->
      jqXHR.abort()
    unless @isValid()
      $('#map-container').removeClass('loading')
      return false
    @holder.submit()

  isValid: ->
    return true unless $('#booking-filter-date').length
    timesState = @.timesState()
    dateFrom = @.datetimeFrom()
    dateTo = @.datetimeTo()
    dateTo = dateTo.add(1, 'day') if timesState.plus_day
    user = getCurrentUser()
    !(dateFrom.isBefore(currentTime()) || timesState.total < 2 || timesState.total > 12 ||
      (user.role == 'chief' && ((dateFrom.isoWeekday() == 7 && dateFrom.hours() < 18 && dateFrom.hours() >= 8) || (dateTo.isoWeekday() == 7 && dateTo.hours() >= 8 && dateTo.hours() < 18))) ||
      (user.role == 'maker' && (dateFrom.isoWeekday() != 7 || dateTo.isoWeekday() != 7 || dateTo.hours() > 18 || dateFrom.hours() < 8 || (dateTo.hours() == 18 && dateTo.minutes() > 0))))

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
    date = formatFullDate(@holder.find('#bookingRequestFromTime').val(), @holder.find('#booking-filter-date').val())
    date = date.add(1, 'day') if date.hour() == 0 && date.minutes() == 0
    date

  datetimeTo: ->
    dateFrom = @datetimeFrom()
    date = formatFullDate(@holder.find('#bookingRequestToTime').val(), @holder.find('#booking-filter-date').val())
    date = date.add(1, 'day') if dateFrom.hour() == 0 && dateFrom.minutes() == 0
    date

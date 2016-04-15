class window.BookingFilter
  constructor: ->
    @holder = $('#booking-filter')

    @holder.on 'ajax:success', ->
      $(document).trigger('map:loading:change', off)

    @holder.on 'ajax:send', ->
      $(document).trigger('map:loading:change', on)

  submit: ->
    @holder.submit()

  timesState: ->
    date = @holder.find('#booking-filter-date').val()
    fromTime = @holder.find('#booking-filter-from').val()
    toTime = @holder.find('#booking-filter-to').val()
    fromDateTime = formatFullDate(fromTime.trim())
    toDateTime = formatFullDate(toTime.trim())
    plusDay = toDateTime <= fromDateTime
    toDateTime = formatFullDate(toTime.trim(), '01/02/1970') if plusDay
    hours = moment.duration(toDateTime.diff(fromDateTime)).asHours()
    {date: date, from: fromTime, to: toTime, total: hours, plus_day: plusDay}

  datetimeFrom: ->
    formatFullDate(@holder.find('#booking-filter-from').val(), @holder.find('#booking-filter-date').val())

class window.TimeSliderRange
  constructor: (holder) ->
    @offset = 8 * 60
    @limit = 4 * 60
    @holder = holder
    @from_target = $(@holder.data('from-target'))
    @to_target = $(@holder.data('to-target'))
    @target = $(@holder.data('target'))
    times = @startTimes()
    if @holder.data('edit')
      @booking = @holder.closest('.edit-booking').data('booking')
      @resource = @holder.closest('.edit-booking').data('resource')
      @from_init = times[0]
      @to_init = times[1]

    @holder.slider(
      range: true,
      min: 0,
      max: 1080,
      step: 30,
      values: times
    ).trigger('slide')

    @holder.on 'slide', (e, ui) =>
      values = if ui && ui.values then ui.values else @holder.slider('option', 'values')
      return false if values[1] - values[0] < @limit
      return false if ui && !@isTimeIfImminent(values)
      return false if ui && !@isReductionIfImminent(values)
      @enableCheckRemainingHours(values) if ui

      from = @sliderValueToTime(values[0])
      @from_target.val(from).trigger('change')
      to = @sliderValueToTime(values[1])
      @to_target.val(to).trigger('change')
      @target.html("#{from} - #{to}")

    @holder.on 'slidestop', (e, ui) =>
      window.booking_filter.submit()

    @holder.trigger('slide')

  isTimeIfImminent: (values) ->
    if @booking && @resource
      minutes_until_start = Math.abs(moment.duration(currentTime().diff(moment(@booking.from_time))).asMinutes())
      if minutes_until_start <= @resource.late_cancellation_limit && @sliderValueToTime(values[0]) != @booking.friendly_from_time
        @showTooltip('Locked. This booking starts in less than 24 hours.')
        return false
    true

  isReductionIfImminent: (values) ->
    if @booking && @resource
      minutes_until_start = Math.abs(moment.duration(currentTime().diff(moment(@booking.from_time))).asMinutes())
      return false if minutes_until_start <= @resource.late_cancellation_limit && values[1] < @to_init
    true

  enableCheckRemainingHours: (values) ->
    if @booking && @resource
      hoursRemaining = $('#my-account-remaining-hours').text().split(' ')[0]
      hoursChange = (values[1] - values[0]) / 60 - (@booking.duration_in_minutes / 60)
      if hoursChange > hoursRemaining
        @showTooltip('This exceeds the hours remaining in your plan, you will be invoiced any extras.')
      else
        @target.tooltip('destroy')

  showTooltip: (message) ->
    @target.attr({
      'data-toggle': 'tooltip',
      'data-placement': 'right',
      'title': message
    })
    unless @target.next('.tooltip').is(':visible') && @target.attr('title') == message
      @target.tooltip('show')

  startTimes: ->
    from = moment("01/02/1970 #{@holder.data('from')}", 'MM/DD/YYYY h:mm a')
    to = moment("01/02/1970 #{@holder.data('to')}", 'MM/DD/YYYY h:mm a')
    [(from.hours() - 8) * 60, (to.hours() - 8 + (if to < from then 24 else 0)) * 60]

  sliderValueToTime: (value) ->
    hours = Math.floor((value + @offset) / 60)
    minutes = (value + @offset) - (hours * 60)
    minutes = "0#{minutes}" if minutes < 10
    minutes = '00' if minutes == 0
    hours = hours - 24 if hours >= 24
    if hours >= 12
      if hours == 12
        res = "#{hours}:#{minutes} PM"
      else
        res = "#{hours - 12}:#{minutes} PM"
    else
      res = "#{hours}:#{minutes} AM"
    if hours == 0
      res = "12:#{minutes} AM"
    res
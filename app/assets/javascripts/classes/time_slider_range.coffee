class window.TimeSliderRange
  constructor: (holder) ->
    @offset = 8 * 60
    @limit = 4 * 60
    @holder = holder
    @from_target = $(@holder.data('from-target'))
    @to_target = $(@holder.data('to-target'))
    @target = $(@holder.data('target'))

    @holder.slider(
      range: true,
      min: 0,
      max: 1080,
      step: 30,
      values: @startTimes()
    ).trigger('slide')

    @holder.on 'slide', (e, ui) =>
      values = if ui then ui.values else @holder.slider('option', 'values')
      return false if values[1] - values[0] < @limit
      from = @sliderValueToTime(values[0])
      @from_target.val(from).trigger('change')
      to = @sliderValueToTime(values[1])
      @to_target.val(to).trigger('change')
      @target.html("#{from} - #{to}")

    @holder.trigger('slide')

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
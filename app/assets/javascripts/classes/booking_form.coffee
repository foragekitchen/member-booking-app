class window.BookingForm
  constructor: (holder) ->
    @holder = holder
    @booking = @holder.data('booking')
    @resource = @holder.data('resource')
    @holder.find('.chosen-select').chosen()
    @disableTimeIfImminent()
    @disableReductionIfImminent()
    @enableCheckRemainingHours()

  disableTimeIfImminent: ->
    minutes_until_start = Math.abs(moment.duration(moment(new Date()).diff(moment(@booking.from_time))).asMinutes())
    if minutes_until_start <= @resource.late_cancellation_limit
      @holder.find('#bookingFrom').prop('disabled', true).trigger("chosen:updated")
      @holder.find('#bookingFrom_chosen').attr({
        "data-toggle": "tooltip",
        "data-placement": "right",
        "title": "Locked. This booking starts in less than 24 hours."
      })
      @holder.find('#bookingFrom_chosen').tooltip( { trigger: 'click' } )
      @holder.find('#bookingFrom_chosen').mouseleave ->
        $(@).tooltip("hide")
    else
      @holder.find('#bookingFrom').prop('disabled', false).trigger("chosen:updated")

  disableReductionIfImminent: ->
    minutes_until_start = Math.abs(moment.duration(moment(new Date()).diff(moment(@booking.from_time))).asMinutes())
    if minutes_until_start <= @resource.late_cancellation_limit
      @holder.find("#bookingTo option[value='#{@holder.find('#bookingTo').val()}']").prevAll().prop('disabled', true)
      @holder.find("#bookingTo").trigger("chosen:updated")
    else
      @holder.find('#bookingTo option').prop('disabled', false).trigger("chosen:updated")

  enableCheckRemainingHours: ->
    @holder.find('form select').change (event) =>
      hoursRemaining = $("#my-account-remaining-hours").text().split(" ")[0]
      hoursChange = @totalHours() - (@booking.duration_in_minutes / 60)
      if hoursChange > hoursRemaining
        @holder.find('#bookingTo_chosen').attr({
          "data-toggle": "tooltip",
          "data-placement": "right",
          "title": "This exceeds the hours remaining in your plan, you will be invoiced any extras."
        })
        @holder.find('#bookingTo_chosen').tooltip('show')
      else
        @holder.find('#bookingTo_chosen').tooltip('destroy')

  totalHours: ->
    fromTime = @holder.find("#bookingFrom").val()
    toTime = @holder.find("#bookingTo").val()
    fromDateTime = formatFullDate(fromTime.trim())
    toDateTime = formatFullDate(toTime.trim())
    toDateTime = formatFullDate(toTime.trim(), '01/02/1970') if toDateTime <= fromDateTime
    moment.duration(toDateTime.diff(fromDateTime)).asHours()

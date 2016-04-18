generateEditForm = (booking,btn) ->

  disableReductionIfImminent(booking)
  enableCheckRemainingHours(booking)


enableCheckRemainingHours = (booking) ->
  $('#editBookingForm select').change (event) ->
    hoursBooking = calculateHours() #TODO - DRY this up with the same fx in resources.coffee
    hoursRemaining = $("#my-account-remaining-hours").text().split(" ")[0]
    hoursChange = hoursBooking - (booking.duration_in_minutes / 60)
    if hoursChange > hoursRemaining
      $('#bookingTo_chosen').attr({
        "data-toggle": "tooltip",
        "data-placement": "right",
        "title": "This exceeds the hours remaining in your plan, you will be invoiced any extras."
      })
      $('#bookingTo_chosen').tooltip('show')
    else
      $('#bookingTo_chosen').tooltip('destroy')

calculateHours = () ->
  fromTime = $("#bookingFrom").val()
  toTime = $("#bookingTo").val()
  fromDateTime = formatFullDate(fromTime.trim())
  toDateTime = formatFullDate(toTime.trim())
  toDateTime = formatFullDate(toTime.trim(), '01/02/1970') if toDateTime <= fromDateTime
  moment.duration(toDateTime.diff(fromDateTime)).asHours()

formatFullDate = (time, date = '01/01/1970') ->
  moment("#{date} #{time}", 'MM/DD/YYYY h:mm a')
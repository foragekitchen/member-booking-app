dateFormat = 'MM/DD/YYYY h:mm a'

$(document).ready ->
  hideEditForm()
  activateEdit()
  activateTooltipsForDisabledCancelButtons()

hideEditForm = () ->
  # can't hide this form on pageload, since Chosen doesn't configure widths correctly unless elements are visible at start
  # we can work-around by calling chosen() again, and then hiding the form
  $(".chosen-select").chosen()
  $("#editFormContainer").addClass("hidden")

activateEdit = () ->
  $("#upcoming-bookings a.btn-edit").click (event) ->
    getBookingFromButton($(this))
    event.preventDefault()

getBookingFromButton = (btn) ->
  wipeBookingForm($(btn).parents("tr").first())
  $.ajax(url: $(btn).attr("href"), dataType: "json").done (data) ->
    generateEditForm(data,btn)

wipeBookingForm = (destination) ->
  # find the form, wipe it
  tr = $("#editFormContainer")
  tr.find("span").text("")
  tr.find("select").val("")
  tr.removeClass("hidden")
  # move it into place
  tr.insertAfter(destination)

generateEditForm = (booking,btn) ->
  $("#bookingId").val(booking.id)
  $("#bookingDate").val(booking.friendly_date)
  $("#inDate").text(booking.friendly_dates)
  $("#bookedFor").text(booking.coworker_full_name)
  $("#bookedBy").text(booking.updated_by)

  times = booking.friendly_times.split(" - ")
  $('#bookingFrom').val(times[0]);
  $('#bookingTo').val(times[1]);
  $('#bookingResource').val(booking.resource_id)
  $('#editBookingForm select').trigger("chosen:updated");

  disableTimeIfImminent(booking)
  disableReductionIfImminent(booking)
  enableCheckRemainingHours(booking)

  $("#editBookingForm .btn-primary").first().click (event) ->
    $("#editBookingForm").attr({"action":"/bookings/" + booking.id})
    $('#bookingFrom').prop('disabled', false).trigger("chosen:updated")
    $("#editBookingForm").submit()

  $('editBookingForm #btn-cancel').click (event) ->
    $("#editFormContainer").addClass("hidden")
    event.preventDefault()

disableTimeIfImminent = (booking) ->
  minutes_until_start = Math.abs(moment.duration(moment(new Date()).diff(moment(booking.from_time))).asMinutes())
  if minutes_until_start <= booking.resource.late_cancellation_limit
    $('#bookingFrom').prop('disabled', true).trigger("chosen:updated")
    $('#bookingFrom_chosen').attr({
      "data-toggle": "tooltip",
      "data-placement": "right",
      "title": "Locked. This booking starts in less than 24 hours."
    })
    $('#bookingFrom_chosen').tooltip({trigger:'click'})
    $('#bookingFrom_chosen').mouseleave ->
      $(this).tooltip("hide")
  else $('#bookingFrom').prop('disabled', false).trigger("chosen:updated")

disableReductionIfImminent = (booking) ->
  minutes_until_start = Math.abs(moment.duration(moment(new Date()).diff(moment(booking.from_time))).asMinutes())
  if minutes_until_start <= booking.resource.late_cancellation_limit
    selectedTime = $("#bookingTo").val()
    $("#bookingTo option[value='" + selectedTime + "']").prevAll().prop('disabled', true)
    $("#bookingTo").trigger("chosen:updated")
  else $('#bookingTo option').prop('disabled', false).trigger("chosen:updated")

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

activateTooltipsForDisabledCancelButtons = () ->
  $(".disabled-cancel").tooltip()

calculateHours = () ->
  fromTime = $("#bookingFrom").val()
  toTime = $("#bookingTo").val()
  fromDateTime = formatFullDate(fromTime.trim())
  toDateTime = formatFullDate(toTime.trim())
  toDateTime = formatFullDate(toTime.trim(), '01/02/1970') if toDateTime <= fromDateTime
  moment.duration(toDateTime.diff(fromDateTime)).asHours()

formatFullDate = (time, date = '01/01/1970') ->
  moment("#{date} #{time}", 'MM/DD/YYYY h:mm a')
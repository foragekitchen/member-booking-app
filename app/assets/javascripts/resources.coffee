jQuery ->
  window.map_display = new MapDisplay
  window.booking_filter = new BookingFilter

  window.booking_filter.submit()

  $('#booking-filter input').trigger('change')

  $('#map-container').on 'click', '.button', (e) ->
    updateBookingForm($(@).parent())
    $(".popover").popover('hide')
    $('#bookingModal').modal()





dateField = '#bookingRequestDate'
timeFromField = '#bookingRequestFromTime'
timeToField = '#bookingRequestToTime'

$(document).ready ->
  activateBookingModal()
  toggleRecurringBookingForm()

activateBookingModal = () ->
  $("#bookingModal button:submit").click (event) ->
    $("#bookingForm").submit()

updateBookingForm = (table) ->
  modal = $('#bookingModal')
  modal.find("h4 span").text( table.attr('data-original-title') )
  html = $(dateField).val() + " from " + $(timeFromField).val() + " - " + $(timeToField).val()
  modal.find(".modal-body h5 span").html(html)
  hoursArr = calculateHours()
  modal.find(".hoursBooking").text("#{hoursArr[3]} hours")
  modal.find("#bookingResourceId").val( table.attr("id").split("-")[1] )
  modal.find("#bookingDate").val(hoursArr[0])
  modal.find("#bookingFrom").val(hoursArr[1])
  modal.find("#bookingTo").val(hoursArr[2])
  isEnoughHoursRemaining(hoursArr[3])

toggleRecurringBookingForm = () ->
  if $("#recur-booking").text().trim() == ""
    $("#recurring-container").css({ opacity: 0.5 })
    $("#recurring-container form input").prop('disabled', true)
  else
    $("#recurring-container").css({ opacity: 0.5 })
    $("#recurring-container").fadeTo("slow",1.0)
    $("#recurring-container form input").prop('disabled', false)

isEnoughHoursRemaining = (hrs_in_booking) ->
  $("#bookingModal .my-plan span.text-warning").hide()
  $("#bookingModal .my-plan span.glyphicon-ok").hide()
  hrs_remaining = $("#hours-remaining").text()
  if hrs_in_booking < hrs_remaining.split(" ")[0]
    $("#bookingModal .my-plan span.glyphicon-ok").show()
  else
    $("#bookingModal .my-plan span.text-warning").show()


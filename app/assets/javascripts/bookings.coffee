$(document).ready ->  
  hideEditForm()
  activateEdit()

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

  $("#editBookingForm .btn-primary").first().click (event) ->
    $("#editBookingForm").attr({"action":"/bookings/" + booking.id})
    $('#bookingFrom').prop('disabled', false).trigger("chosen:updated")
    $("#editBookingForm").submit()

  $('editBookingForm #btn-cancel').click (event) ->
    $("#editFormContainer").addClass("hidden")
    event.preventDefault()
    
disableTimeIfImminent = (booking) ->
  minutes_until_start = Math.abs( convertToUtc(booking.from_time) - convertToUtc(new Date()) ) / 1000 / 60
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
    
convertToUtc = (datetime) ->
  utc = (new Date(datetime)).toISOString()
  return new Date(utc)
  
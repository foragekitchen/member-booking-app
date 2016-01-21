$(document).ready ->  
  hideEditForm()
  activateEdit()

hideEditForm = () ->
  # can't hide this form on pageload, since Chosen doesn't configure widths correctly unless elements are visible at start
  # we can work-around by calling chosen() again, and then hiding the form
  $(".chosen-select").chosen()
  $("#editForm").addClass("hidden") 

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
  tr = $("#editForm")
  tr.find("span").text("")
  tr.find("select").val("")
  tr.removeClass("hidden")
  # move it into place
  tr.insertAfter(destination)

generateEditForm = (booking,btn) ->
  $("#booking_id").val(booking.id)
  $("#inDate").text(booking.friendly_dates)
  $("#bookedFor").text(booking.coworker_full_name)
  $("#bookedBy").text(booking.updated_by)
  
  times = booking.friendly_times.split(" - ")
  $('#fromTime').val(times[0]);
  $('#toTime').val(times[1]);
  $('#resource').val(booking.resource_name)
  $('#editForm select').trigger("chosen:updated");  
  
  $('#btn-cancel').click (event) ->
    $("#editForm").addClass("hidden")
    event.preventDefault()
  
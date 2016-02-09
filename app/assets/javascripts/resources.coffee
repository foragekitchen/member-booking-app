$(document).ready ->  
  getResources()
  activateFilter()
  activateBookingModal()
  toggleRecurringBookingForm()

getResources = () ->
  $.ajax(url: "/resources", dataType: "json").done (json) ->
    positionTables(json)

positionTables = (resources) ->
  createTable resource for resource in resources
  markAvailable()
  
activateBookingModal = () ->
  $("#bookingModal a.btn-change").click (event) ->
    $("#bookingModal").modal('hide')
    event.preventDefault()
  $("#bookingModal .btn-primary").first().click (event) ->
    $("#bookingForm").submit()

activateFilter = () ->
  $("#bookingFilters select").change (event) ->
    hoursArr = calculateHours()
    #TODO - query for the booking minimum time, instead of hardcoding 4 hours here
    if hoursArr[3] < 4
      $("#bookingFilters .btn-default").prop('disabled', true)
      $('#bookingFilters .btn-default').attr({
        "data-toggle": "tooltip",
        "data-placement": "right", 
        "title": "Booking must be at least 4 hours."
      })
      $('#bookingFilters .btn-default').tooltip('show')
    else
      $("#bookingFilters .btn-default").prop('disabled', false)
      $('#bookingFilters .btn-default').tooltip('destroy')
  $("#bookingFilters").submit (event) ->
    markAvailable()
    event.preventDefault()

markAvailable = () ->
  if $("#bookingRequestDate").val()
    requestFrom = $("#bookingRequestDate").val() + "T" + $("#bookingRequestFromTime").val()
    requestTo = $("#bookingRequestDate").val() + "T" + $("#bookingRequestToTime").val()
    $.ajax(url: "/resources?bookingRequestFrom=#{requestFrom}&bookingRequestTo=#{requestTo}", dataType: "json").done (json) ->
      $("#map-container .resource").removeClass "available"
      for resourceID in json
        $("#map-container").find("#resource-#{resourceID}").addClass "available" 
        $("#map-container").find("#resource-#{resourceID} div.button").click (event) -> 
          updateBookingForm($(this).parent())
          $(".popover").popover('hide')
          $('#bookingModal').modal()

createTable = (table) ->
  div = $ "<div>" # draw table
  div.addClass "resource"
  div.attr({
    "id": "resource-" + table.id
    "data-toggle": "popover"
    "title": "#{table.name} #{table.resource_type_name}"
    "data-content": table.description
  })
  div.popover({animation: false, placement: "left", html: true, trigger: "hover"})
  button = $ "<div>" # put button inside to open the booking modal
  button.addClass "button"
  div.append button
  if $.isArray(table.location) # figure out the position
    pos = getPosition(table.location)
    div.css({top: pos[0], left: pos[1] })
  $("#map-container").append div
  
getPosition = (latlong) ->  
  scale = .76 #Used for converting from inches (distance away from top left corner of space) to pixels (representing on the image)
  offsetTop = 55 #Offset for extra border on the map around the actual space
  offsetLeft = 45
  return [latlong[0]*scale+offsetTop,latlong[1]*scale+offsetLeft]
  
updateBookingForm = (table) ->
  modal = $('#bookingModal')
  modal.find("h4 span").text( table.attr('data-original-title') )
  html = $("#bookingRequestDate").val() + " from " + $("#bookingRequestFromTime").val() + " - " + $("#bookingRequestToTime").val()
  modal.find(".modal-body h5 span").html(html)
  hoursArr = calculateHours()
  modal.find(".hoursBooking").text("#{hoursArr[3]} hours")
  modal.find("#bookingResourceId").val( table.attr("id").split("-")[1] )
  modal.find("#bookingDate").val(hoursArr[0])
  modal.find("#bookingFrom").val(hoursArr[1])
  modal.find("#bookingTo").val(hoursArr[2])
  
toggleRecurringBookingForm = () ->
  if $("#recur-booking").text().trim() == "" 
    $("#recurring-container").css({ opacity: 0.5 })
    $("#recurring-container form input").prop('disabled', true)
  else
    $("#recurring-container").css({ opacity: 0.5 })
    $("#recurring-container").fadeTo("slow",1.0)
    $("#recurring-container form input").prop('disabled', false)
    
calculateHours = () ->  
  date = $("#bookingRequestDate").val()
  fromTime = $("#bookingRequestFromTime").val()
  toTime = $("#bookingRequestToTime").val()
  hours = ( new Date("1970-1-1 " + toTime) - new Date("1970-1-1 " + fromTime) ) / 1000 / 60 / 60
  return [date,fromTime,toTime,hours]
  
  
  
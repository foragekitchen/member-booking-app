$(document).ready ->  
  getResources()
  activateFilter()
  activateBookingModal()

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
  $("#bookingFilters").submit (event) ->
    markAvailable()
    event.preventDefault()

markAvailable = () ->
  if $("#bookingRequestDate").val()
    requestFrom = $("#bookingRequestDate").val() + "T" + $("#bookingRequestFromTime").val()
    requestTo = $("#bookingRequestDate").val() + "T" + $("#bookingRequestToTime").val()
    $.ajax(url: "/resources?bookingRequestFrom=#{requestFrom}&bookingRequestTo=#{requestTo}", dataType: "json").done (json) ->
      $("#map-container .resource").removeClass "available"
      $("#map-container").find("#resource-#{resourceID}").addClass "available" for resourceID in json

createTable = (table) ->
  div = $ "<div>" # draw table
  div.addClass "resource"
  div.attr({
    "id": "resource-" + table.id
    "data-toggle": "popover"
    "title": "#{table.name} #{table.type}"
    "data-content": table.description
  })
  div.popover({animation: false, placement: "left", html: true, trigger: "hover"})
  button = $ "<div>" # put button inside to open the booking modal
  button.addClass "button"
  button.click (event) ->
    updateBookingForm($(this).parent())
    $(".popover").popover('hide')
    $('#bookingModal').modal()
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
  date = $("#bookingRequestDate").val()
  fromTime = $("#bookingRequestFromTime").val()
  toTime = $("#bookingRequestToTime").val()
  modal = $('#bookingModal')
  modal.find("h4 span").text( table.attr('data-original-title') )
  html = $("#bookingRequestDate").val() + " from " + $("#bookingRequestFromTime").val() + " - " + $("#bookingRequestToTime").val()
  modal.find(".modal-body h5 span").html(html)
  hours = ( new Date("1970-1-1 " + toTime) - new Date("1970-1-1 " + fromTime) ) / 1000 / 60 / 60
  modal.find(".hoursBooking").text("#{hours} hours")
  modal.find("#bookingResourceId").val( table.attr("id").split("-")[1] )
  modal.find("#bookingDate").val(date)
  modal.find("#bookingFrom").val(fromTime)
  modal.find("#bookingTo").val(toTime)
  
  
  
  
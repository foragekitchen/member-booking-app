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
  $("#bookingModal button:submit").click (event) ->
    $("#bookingForm").submit()

activateFilter = () ->
  $("#disable-map").hide()
  $("#bookingFilters select, #bookingFilters input").change (event) ->
    hoursArr = calculateHours()
    #TODO - query for the booking minimum/maximum time, instead of hardcoding 4/12 hours here
    if moment($('#bookingRequestDate').val(), 'MM/DD/YYYY').isBefore(moment(new Date()), 'day')
      changeMapState(false, 'Booking cannot be in the past.')
    else if hoursArr[3] < 4
      changeMapState(false, 'Booking must be at least 4 hours.')
    else if hoursArr[3] > 12
      changeMapState(false, 'Booking cannot be more than 12 hours.')
    else
      changeMapState(true)
  $("#bookingFilters").submit (event) ->
    markAvailable()
    event.preventDefault()

markAvailable = () ->
  if $("#bookingRequestDate").val()
    requestFrom = $("#bookingRequestDate").val() + "T" + $("#bookingRequestFromTime").val()
    requestTo = $("#bookingRequestDate").val() + "T" + $("#bookingRequestToTime").val()
    changeMapState(false)
    $.ajax(url: "/resources?bookingRequestFrom=#{requestFrom}&bookingRequestTo=#{requestTo}", dataType: "json").done (json) ->
      $("#map-container .resource").removeClass "available"
      for resourceID in json
        $("#map-container").find("#resource-#{resourceID}").addClass "available"
        $("#map-container").find("#resource-#{resourceID} div.button").click (event) ->
          updateBookingForm($(this).parent())
          $(".popover").popover('hide')
          $('#bookingModal').modal()
      changeMapState(true)

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
  isEnoughHoursRemaining(hoursArr[3])

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
  fromDateTime = formatFullDate(fromTime.trim())
  toDateTime = formatFullDate(toTime.trim())
  toDateTime = formatFullDate(toTime.trim(), '1970-01-02') if toDateTime <= fromDateTime
  hours = moment.duration(toDateTime.diff(fromDateTime)).asHours()
  return [date, fromTime, toTime, hours]

isEnoughHoursRemaining = (hrs_in_booking) ->
  $("#bookingModal .my-plan span.text-warning").hide()
  $("#bookingModal .my-plan span.glyphicon-ok").hide()
  hrs_remaining = $("#hours-remaining").text()
  if hrs_in_booking < hrs_remaining.split(" ")[0]
    $("#bookingModal .my-plan span.glyphicon-ok").show()
  else
    $("#bookingModal .my-plan span.text-warning").show()

changeMapState = (state = true, message = '') ->
  $button = $('#bookingFilters :submit')
  $map_backdrop = $('#disable-map')
  $map_backdrop[if state then 'hide' else 'show'].apply($map_backdrop, [])
  $button.prop('disabled', !state)
  if message && !state
    $button.attr({
      "data-toggle": "tooltip",
      "data-placement": "right",
      "title": message,
      "data-original-title": message
    })
    $button.tooltip('show')
  else
    $button.tooltip('destroy')

formatFullDate = (time, date = '1970-01-01') ->
  moment("#{date} #{time}", 'YYYY-MM-DD h:mm a')
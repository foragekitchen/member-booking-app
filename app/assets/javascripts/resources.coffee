$(document).ready ->  
  getResources()

getResources = () ->
  $.ajax(url: "/resources", dataType: "json").done (json) ->
    console.log json
    positionTables(json)

positionTables = (resources) ->
  console.log "Ok got resources"
  createTable resource for resource in resources
  
createTable = (table) ->
  div = $ "<div>"
  div.addClass "resource"
  div.id = table.id
  div.attr({
    "data-toggle": "popover"
    "title": "#{table.name} #{table.type}"
    "data-content": table.description
  })
  div.popover({animation: false, placement: "left", html: true, trigger: "hover"})
  if $.isArray(table.location)
    pos = getPosition(table.location)
    div.css({top: pos[0], left: pos[1] })
  $("#map-container").append div
  
getPosition = (latlong) ->  
  scale = .76 #Used for converting from inches (distance away from top left corner of space) to pixels (representing on the image)
  offsetTop = 55 #Offset for extra border on the map around the actual space
  offsetLeft = 45
  return [latlong[0]*scale+offsetTop,latlong[1]*scale+offsetLeft]
  
  
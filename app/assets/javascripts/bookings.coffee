$(document).ready ->  
  getResources()

getResources = () ->
  $.ajax(url: "/bookings").done (json) ->
    console.log json


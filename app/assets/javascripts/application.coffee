#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require moment
#= require bootstrap
#= require chosen-jquery
#= require_tree .

$(document).ready ->
  $('.collapse').collapse()
  $(".chosen-select").chosen()
  $(".datepicker").datepicker()
  lightUpActiveNav()
  enableMyAccountPopover()

lightUpActiveNav = () ->
  current_controller = $("body").attr("id")
  $("#nav-main .#{current_controller}-nav").addClass "active"

enableMyAccountPopover = () ->
  html = $("#my_account_popover").html()
  $("li.accounts-nav a").popover({
      "content": html,
      "html": true,
      "placement": "bottom",
      "container": "body"
    })

# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require jquery-ui
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

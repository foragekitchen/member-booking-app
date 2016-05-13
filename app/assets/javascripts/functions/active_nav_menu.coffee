jQuery ->
  $('body').activeNavMenu()

$.fn.activeNavMenu = ->
  @each ->
    $("#nav-main .#{$(@).attr('id')}-nav").addClass('active')
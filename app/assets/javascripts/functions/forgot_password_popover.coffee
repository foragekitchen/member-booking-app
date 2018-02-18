jQuery ->
  $('#forgot_password_popover').forgotPasswordPopover()

$.fn.forgotPasswordPopover = ->
  @each ->
    $('.pull-right a').popover({
      'content': $(@).html(),
      'html': true,
      'placement': 'top',
      'container': 'body'
    })

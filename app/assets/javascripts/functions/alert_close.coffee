jQuery ->
  $('.alert:visible').autoClose()

$.fn.autoClose = ->
  @each =>
    setTimeout =>
      $(@).fadeOut('slow')
    , 5000

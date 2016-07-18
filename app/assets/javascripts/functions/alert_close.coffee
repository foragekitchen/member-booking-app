jQuery ->
  $('.alert:visible').autoClose()

$.fn.autoClose = ->
  @each ->
    $me = $(@)
    setTimeout(->
      $me.fadeOut('slow')
    , 5000)

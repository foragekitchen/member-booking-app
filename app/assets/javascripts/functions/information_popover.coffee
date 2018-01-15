jQuery ->
  $('#information_popover').infoPopover()

$.fn.infoPopover = ->
  @each ->
    $('li.info-nav a').popover({
      'content': $(@).html(),
      'html': true,
      'placement': 'bottom',
      'container': 'body'
    })

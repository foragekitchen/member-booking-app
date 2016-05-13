jQuery ->
  $('#my_account_popover').accountPopover()

$.fn.accountPopover = ->
  @each ->
    $('li.accounts-nav a').popover({
      'content': $(@).html(),
      'html': true,
      'placement': 'bottom',
      'container': 'body'
    })

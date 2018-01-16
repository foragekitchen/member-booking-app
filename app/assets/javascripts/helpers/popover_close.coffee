$(document).on 'click', (e) ->
  $('[data-toggle="popover"],[data-original-title]').each ->
#the 'is' for buttons that trigger popups
#the 'has' for icons within a button that triggers a popup
    if !$(this).is(e.target) and $(this).has(e.target).length == 0 and $('.popover').has(e.target).length == 0
      (($(this).popover('hide').data('bs.popover') or {}).inState or {}).click = false
    # fix for BS 3.3.6
    return
  return
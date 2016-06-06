jQuery ->
  $('form.disable-on-submit').bind('submit', (e) ->
    $submit = $(@).find(':submit')
    if $submit.is('.disabled')
      e.preventDefault()
      return false
    $submit.addClass('disabled')
  )

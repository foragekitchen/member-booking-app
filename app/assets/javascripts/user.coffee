@getCurrentUser = ->
  if Cookies.get('user') then JSON.parse(Cookies.get('user')) else {}

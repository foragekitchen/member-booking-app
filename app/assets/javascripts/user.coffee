@getCurrentUser = ->
  if $.cookie('user') then JSON.parse($.cookie('user')) else {}
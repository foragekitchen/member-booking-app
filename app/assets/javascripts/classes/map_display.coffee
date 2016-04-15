class window.MapDisplay
  constructor: ->
    @holder = $('#map-container')
    @map_loading = new MapLoading

  turnOff: ->
    @holder.find('.resource').removeClass("available")

  removeResources: ->
    @holder.find('.resource').remove()

  addResource: (content) ->
    content = $(content)
    @holder.append(content)
    content.popover( { animation: false, placement: "left", html: true, trigger: "hover" } )

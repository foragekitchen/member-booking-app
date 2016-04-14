class window.MapDisplay
  constructor: ->
    @holder = $('#map-container')

  turnOff: ->
    @holder.find('.resource').removeClass("available")

  removeResources: ->
    @holder.find('.resource').remove()

  addResource: (content) ->
    @holder.append(content)

class window.MapLoading
  constructor: ->
    @map = $('#disable-map')
    @holder = $('#filter-time-slider')

    $(document).on 'map:loading:change', (e, state, message) =>
      @map[if !state then 'hide' else 'show'].apply(@map, [])
      if message && state
        return if @holder.next('.tooltip').is(':visible') && @holder.attr('title') == message
        @holder.attr({
          'data-toggle': 'tooltip',
          'data-placement': 'right',
          'title': message,
          'data-original-title': message
          'data-trigger': 'manual'
        })
        @holder.tooltip('show')
      else
        @holder.tooltip('destroy')

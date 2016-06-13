class window.MapLoading
  constructor: ->
    @map = $('#map-container')
    @holder = $('#filter-time-slider')

    $(document).on 'map:loading:change', (e, state, message) =>
      @map[if !state then 'removeClass' else 'addClass'].apply(@map, ['disabled'])
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

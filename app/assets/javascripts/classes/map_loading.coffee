class window.MapLoading
  constructor: ->
    @map = $('#disable-map')
    @dropdown = $('.dropdown.dropdown-time-range')

    $(document).on 'map:loading:change', (e, state, message) =>
      @map[if !state then 'hide' else 'show'].apply(@map, [])
      if message && state
        return if @dropdown.next('.tooltip').is(':visible') && @dropdown.attr('title') == message
        @dropdown.attr({
          "data-toggle": "tooltip",
          "data-placement": "right",
          "title": message,
          "data-original-title": message
          "data-trigger": "manual"
        })
        @dropdown.tooltip('show')
      else
        @dropdown.tooltip('destroy')

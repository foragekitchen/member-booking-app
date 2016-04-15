class window.MapLoading
  constructor: ->
    @map = $('#disable-map')
    @button = $('#booking-filter :submit')

    $(document).on 'map:loading:change', (e, state, message) =>
      @map[if !state then 'hide' else 'show'].apply(@map, [])
      @button.prop('disabled', state)
      if message && state
        @button.attr({
          "data-toggle": "tooltip",
          "data-placement": "right",
          "title": message,
          "data-original-title": message
        })
        @button.tooltip('show')
      else
        @button.tooltip('destroy')

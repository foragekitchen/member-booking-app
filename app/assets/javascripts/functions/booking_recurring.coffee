jQuery ->
  $('#recur-booking').bookingRecurring()

$.fn.bookingRecurring = ->
  $container = $('#recurring-container')
  $input = $container.find('input')
  @each ->
    if $(@).text().trim() == ''
      $container.css({ opacity: 0.5 })
      $input.prop('disabled', true)
    else
      $container.find('.alert').removeClass('hide')
      $container.css({ opacity: 0.5 }).fadeTo('slow', 1.0)
      $input.prop('disabled', false)

jQuery ->
  $('#recur-booking').bookingRecurring()

$.fn.bookingRecurring = ->
  $container = $('#recurring-container')
  $input = $container.find('input')
  @each ->
    if $(@).text().trim().length
      $container.find('.alert').removeClass('hide')
      $container.removeClass('disabled')

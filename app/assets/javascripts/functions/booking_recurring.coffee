jQuery ->
  $('#recur-booking').bookingRecurring()

$.fn.bookingRecurring = ->
  $container = $('#recurring-container')
  $input = $container.find('input')
  @each ->
    if $(@).text().trim().length
      $container.find('.alert').removeClass('hide').autoClose()
      $container.removeClass('disabled')
    $(@).closest('form').on 'submit', (e) ->
      return if $('#booking_dates').val()
      e.preventDefault()
      false

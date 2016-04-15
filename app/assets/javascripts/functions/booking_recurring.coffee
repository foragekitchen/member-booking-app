jQuery ->
  $('#recur-booking').bookingRecurring()

$.fn.bookingRecurring = ->
  @each ->
    if $(@).text().trim() == ''
      $('#recurring-container').css({ opacity: 0.5 })
      $('#recurring-container form input').prop('disabled', true)
    else
      $('#recurring-container').css({ opacity: 0.5 })
      $('#recurring-container').fadeTo('slow',1.0)
      $('#recurring-container form input').prop('disabled', false)

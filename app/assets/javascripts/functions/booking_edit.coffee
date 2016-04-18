jQuery ->
  $('.booking-edit, .booking-close').bookingEdit()

$.fn.bookingEdit = ->
  @each ->
    $(@).on 'click', (e) ->
      e.preventDefault()
      $("#edit-booking-#{$(@).data('id')}").toggleClass('hidden')
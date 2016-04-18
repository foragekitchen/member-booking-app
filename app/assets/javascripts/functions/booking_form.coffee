jQuery ->
  $('.edit-booking').bookingForm()

$.fn.bookingForm = ->
  @each ->
    new BookingForm($(@))
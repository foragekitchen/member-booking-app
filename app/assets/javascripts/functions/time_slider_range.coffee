jQuery ->
  $('.time-slider-range').timeSliderRange()

$.fn.timeSliderRange = ->
  @each ->
    new TimeSliderRange($(@))
class window.BookingModal
  constructor: (table) ->
    @holder = $('#bookingModal')
    @fillModalForm(table)
    $('.popover').popover('hide')
    $('#bookingModal').modal()
    @holder.find('.invite-friend-js').removeClass('hide') if getCurrentUser().maker

  fillModalForm: (table) ->
    timesState = window.booking_filter.timesState()
    @holder.find('h4 span').text( table.attr('data-original-title') )
    html = "#{timesState['date']} from #{timesState['from']} to #{timesState['to']}"
    @holder.find('.modal-body h5 span').html(html)
    @holder.find('.hoursBooking').text("#{timesState['total']} hours")
    @fillValue('#bookingResourceId', table.attr('id').split('-')[1])
    @fillValue('#bookingDate', timesState['date'])
    @fillValue('#bookingFrom', timesState['from'])
    @fillValue('#bookingTo', timesState['to'])
    @isEnoughHoursRemaining(timesState['total'])

  fillValue: (selector, value) ->
     @holder.find(selector).val(value)

  isEnoughHoursRemaining: (total) ->
    @holder.find('.my-plan span.text-warning, .my-plan span.glyphicon-ok').hide()
    hrs_remaining = $('#hours-remaining').text()
    if total < hrs_remaining.split(' ')[0]
      @holder.find('.my-plan span.glyphicon-ok').show()
    else
      @holder.find('.my-plan span.text-warning').show()


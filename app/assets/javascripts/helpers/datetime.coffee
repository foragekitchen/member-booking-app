@formatFullDate = (time, date = '01/01/1970') ->
  moment("#{date} #{time}", 'MM/DD/YYYY h:mm a')

@currentTime = ->
  time = moment(new Date()).tz('America/Los_Angeles').format().split('-')
  time.pop()
  moment(time.join('-'))
@formatFullDate = (time, date = '01/01/1970') ->
  moment("#{date} #{time}", 'MM/DD/YYYY h:mm a')
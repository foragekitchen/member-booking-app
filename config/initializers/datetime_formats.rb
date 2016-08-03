{booking: '%a, %b %-d',
 booking_short: '%b %-d',
 booking_day: '%m/%d/%Y',
 booking_time: '%l:%M %p',
 nexudus: '%Y-%m-%dT%H:%M:00Z',
 google_calendar: '%Y%m%dT%H%M00Z',
 universal_date: '%m/%d/%YT%l:%M %p %z'}.each do |name, format|
  Time::DATE_FORMATS[name] = format
end

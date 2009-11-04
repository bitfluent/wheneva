Time::DATE_FORMATS[:appointment_date] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}") }
Time::DATE_FORMATS[:appointment_date_short] = "%d %b %y" #th Nov 09
Time::DATE_FORMATS[:appointment_time] = "%l %p"
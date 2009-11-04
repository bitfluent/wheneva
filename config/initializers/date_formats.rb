Time::DATE_FORMATS[:appointment_date] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}") }
Time::DATE_FORMATS[:appointment_date_short] = "%d %b %y" #th Nov 09
Time::DATE_FORMATS[:appointment_time] = "%l %p"
Time::DATE_FORMATS[:slot] = lambda { |time| time.strftime("%A at #{time.hour > 12 ? time.hour - 12 : time.hour}#{time.hour > 11 ? "pm" : "am"}") } # Thursday at 9am

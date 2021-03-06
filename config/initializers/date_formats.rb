Time::DATE_FORMATS[:appointment_date] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}") }
Time::DATE_FORMATS[:appointment_date_short] = "%d %b %y" #th Nov 09
Time::DATE_FORMATS[:appointment_time] = "%l %p"
Time::DATE_FORMATS[:slot] = lambda { |time| time.strftime("%b #{time.day.ordinalize} at #{time.hour > 12 ? time.hour - 12 : time.hour}#{time.hour > 11 ? "pm" : "am"}") } # Nov 5th at 9am
Time::DATE_FORMATS[:current_date] = lambda { |time| time.strftime("#{time.day.ordinalize} %b %Y") } # 4th Nov 2009

class Time
  def self.military_hour_to_civil_hour(hour)
    mod = (hour % 12)
    mod + (12 * (mod > 0 ? 0 : 1))
  end
end

# Add convenient date/time formats
Date::DATE_FORMATS.merge!(
  :std => lambda {|date| date.strftime("#{date.month}/#{date.day}/%Y") },
  :nice => lambda {|date| date.strftime("%A, %B #{date.day}, %Y") }
)
Time::DATE_FORMATS.merge!(
  :std => lambda {|time|
    chour = Time.military_hour_to_civil_hour(time.hour)
    time.strftime("#{time.month}/#{time.day}/%Y #{chour}:%M %p")
  },
  :nice => lambda {|time|
    chour = Time.military_hour_to_civil_hour(time.hour)
    time.strftime("%A, %B #{time.day}, %Y at #{chour}:%M %p")
  }
)
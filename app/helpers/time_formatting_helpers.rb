
module TimeFormattingHelpers
  extend self

  def format_time_as(format, time, today=Date.today)
    __send__("_format_time_as_#{format}", time, today)
  end

  #---

  def _format_time_as_std(time, today)
    time.strftime("#{time.month}/#{time.day}/%Y at %I:%M %P")
  end

  def _format_time_as_std2(time, today)
    time.strftime("%B #{time.day}, %Y at %I:%M %P")
  end
end

class Duration
  def initialize(dur)
    @dur = dur
  end

  def to_s(abbr = false)
    h = self.to_hash

    [:days, :hours, :minutes, :seconds].map do |unit|
      "#{h[unit]} #{label(unit, abbr, h[unit] == 1)}" if h.has_key?(unit)
    end.compact.join(" ")
  end

  def to_hash
    return {} if @dur < 0

    case @dur
    when (0.second..59.seconds)
      {:seconds => @dur}
    when (1.minute..(10.minutes - 1.second))
      {:minutes => to_minutes(@dur), :seconds => (@dur - to_minutes(@dur).minutes)}
    when (10.minutes..(60.minutes - 1.second))
      {:minutes => to_minutes(@dur)}
    when (1.hour..(10.hours - 1.second))
      {:hours => to_hours(@dur), :minutes => to_minutes(@dur - to_hours(@dur).hours)}
    when (10.hours..(24.hours - 1.second))
      {:hours => to_hours(@dur)}
    when (1.day..(7.days - 1.second))
      {:days => to_days(@dur), :hours => to_hours(@dur - to_days(@dur).days)}
    else
      {:days => to_days(@dur)}
    end
  end

  protected

  def to_days(dur)
    dur / 1.day
  end

  def to_hours(dur)
    dur / 1.hour
  end

  def to_minutes(dur)
    dur / 1.minute
  end

  def label(unit, abbreviated, singular = false)
    labels = if abbreviated
      {:seconds => "sec",     :minutes => "min",     :hours => "hr",    :days => "day"}
    elsif singular
      {:seconds => "second",  :minutes => "minute",  :hours => "hour",  :days => "day"}
    else
      {:seconds => "seconds", :minutes => "minutes", :hours => "hours", :days => "days"}
    end

    labels[unit]
  end
end


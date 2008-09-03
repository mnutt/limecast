class Integer
  def to_duration(abbr = true)
    h = self.to_duration_hash

    [:days, :hours, :minutes, :seconds].map do |unit|
      "#{h[unit]} #{time_label(unit, abbr, h[unit] == 1)}" if h.has_key?(unit)
    end.compact.join(" ")
  end

  protected

  def to_duration_hash
    return {} if self < 0

    case self
    when (0.second..59.seconds)
      {:seconds => self}
    when (1.minute..(10.minutes - 1.second))
      {:minutes => self.to_minutes, :seconds => (self - self.to_minutes.minutes)}
    when (10.minutes..(60.minutes - 1.second))
      {:minutes => self.to_minutes}
    when (1.hour..(24.hours - 1.second))
      {:hours => self.to_hours, :minutes => (self - self.to_hours.hours).to_minutes}
    when (1.day..(7.days - 1.second))
      {:days => self.to_days, :hours => (self - self.to_days.days).to_hours}
    else
      {:days => self.to_days}
    end
  end

  def time_label(unit, abbreviated, singular = false)
    labels = if abbreviated
      {:seconds => "sec",     :minutes => "min",     :hours => "hr",    :days => "day"}
    elsif singular
      {:seconds => "second",  :minutes => "minute",  :hours => "hour",  :days => "day"}
    else
      {:seconds => "seconds", :minutes => "minutes", :hours => "hours", :days => "days"}
    end

    labels[unit]
  end

  def to_days
    self / (60 * 60 * 24)
  end

  def to_hours
    self / (60 * 60)
  end

  def to_minutes
    self / 60
  end
end


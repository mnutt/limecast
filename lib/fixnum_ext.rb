class Fixnum
  def to_duration
    return "" if self <= 0

    case self
    when (1.second..59.seconds)
      "#{self} sec"
    when (1.minute..(10.minutes - 1.second))
      "#{self.to_minutes} min #{self - self.to_minutes.minutes} sec"
    when (10.minutes..(60.minutes - 1.second))
      "#{self.to_minutes} min"
    when (1.hour..(24.hours - 1.second))
      "#{self.to_hours} hr #{(self - self.to_hours.hours).to_minutes} min"
    when (1.day..(7.days - 1.second))
      "#{self.to_days} day #{(self - self.to_days.days).to_hours} hr"
    else
      "#{self.to_days} day"
    end
  end

  protected

  def to_days(format)
    self / (60 * 60 * 24)
  end

  def to_hours
    self / (60 * 60)
  end

  def to_minutes
    self / 60
  end
end


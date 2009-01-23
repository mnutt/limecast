class Date
  alias :old_to_s :to_s

  def to_s(format = nil)
    if format == nil
      to_s(:long_ordinal)
    elsif format == :url
      strftime("%Y %b %d").gsub(/(\s+)0/, " ").gsub(" ", "-")
    else
      old_to_s(format)
    end
  end
end

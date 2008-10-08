class Date
  alias :old_to_s :to_s

  def to_s(format = nil)
    if format == nil
      strftime("%Y %b %e").gsub(/(\s+)0/, " ")
    elsif format == :url
      strftime("%Y %b %d").gsub(/(\s+)0/, " ").gsub(" ", "-")
    else
      old_to_s(format)
    end
  end
end

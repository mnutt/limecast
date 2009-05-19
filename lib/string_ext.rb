class String
  def to_url
    url = self.
      sub(%r{^[^:]+://}, "").     # Removes protocol
      sub(%r{^www\.}, "").        # Removes www
      sub(%r{\?.*$}, "").         # Removes trailing parameters
      sub(%r{index\.html$}, "").  # Removes trailing index.html
      sub(%r{/$}, "")             # Removes trailing slash

    parts = url.split('/')
    parts.first.downcase! if parts.first
    parts.join('/')
  end
  
  # This is different from #next/#succ because it only increments digits.
  # Also, if it is incrementing from x-digits to y-digits, it will add the extra
  # digit instead of resetting to 0 and keeping x-digits.
  # 
  #   "abcd".increment      #=> "abcd1"
  #   "THX1138".increment   #=> "THX1139"
  #   "<<koala>>".increment #=> "<<koala>>1"
  #   "1999zzz".increment   #=> "1999zzz1"
  #   "ZZZ9999".increment   #=> "ZZZ10000"
  #   "***".increment       #=> "***1"
  #   "123".increment       #=> "124"
  #   " 123 ".increment     #=> " 123 1"
  #   " 123 ".increment     #=> " 123 1"
  #
  # You can pass in an optional format for the numbers where %s is the placeholder
  # for the digits:
  #
  #   " foobar (1)".increment #=> " foobar (2)"
  #   " foobar (789) ".increment #=> " foobar (789) (1)"
  #
  def increment(format=nil) 
    regexp = format ? Regexp.new(Regexp.escape(format).gsub('%s', '\d+')) : /\d/
    parts = format ? split(/(#{regexp})|(\D)/) : split(/(\D)/)
    num = (format || "%s") % 0
    parts.push(num) unless parts[-1] =~ regexp
    parts[-1] = if format 
                  parts[-1].sub(/(\d+)/) { |m| Integer(m) + 1  }
                else
                  Integer(parts[-1]) + 1
                end
    parts.join
  end
  
  def increment!(format=nil)
    replace(increment(format))
  end
end

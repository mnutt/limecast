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
  def increment
    parts = split(/(\D)/)
    parts.push("0") unless parts[-1] =~ /\d/
    parts[-1] = Integer(parts[-1]) + 1
    parts.join
  end
  
  def increment!
    replace(increment)
  end
end

class Integer
  def to_duration
    Duration.new(self)
  end

  def to_file_size
    FileSize.new(self)
  end

  def to_bitrate
    Bitrate.new(self)
  end
  
  # 1000000 returns '1,000,000'
  def to_formatted_s
    self.to_s.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse
  end
end


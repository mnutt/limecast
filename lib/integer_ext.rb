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
end


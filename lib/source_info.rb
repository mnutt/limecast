class SourceInfo
  attr_reader :raw_info, :source
  attr_accessor :file_size, :file_name, :sha1hash, :content_type, :bitrate

  def initialize(raw_info, source)
    @raw_info = raw_info
    @source = source
    source.update_attribute(:ffmpeg_info, raw_info)
  end

  def inspect
    self.to_hash.inspect
  end

  def to_hash
    {
      :duration    => duration,
      :bitrate     => bitrate,
      :video_codec => video_codec,
      :audio_codec => audio_codec,
      :resolution  => [*resolution],
      :framerate   => framerate,
      :file_format => file_format,
      :file_size   => file_size,
      :file_name   => file_name,
      :sha1hash    => sha1hash
    }
  end

  def duration
    if raw_info =~ /Duration: ([^:]*):([^:]*):([^,]*)/
      hours   = $1.to_i
      minutes = $2.to_i
      seconds = $3.to_f
      
      duration = hours * 60 * 60 + minutes * 60 + seconds
    end
  rescue
    nil
  end

  def file_format
    $1 if raw_info =~ /Input \#0, ([^,]*)/
  end
  
  def resolution
    raw_info =~ /([\d]{3,4})x([\d]{3,4})/ ? [$1, $2].map(&:to_i) : []
  end
  
  def framerate
    $1.strip if raw_info =~ /\b(\d+\.?\d* tb\([rc]\)|\d+\.?\d* fps\(r\))/
  end
  
  def bitrate
    $1.to_i if raw_info =~ /bitrate: ([^ ]*)/
  rescue
    nil
  end
  
  def video_codec
    $1 if raw_info =~ /Video: ([^\n,]*)/
  rescue
    nil
  end
  
  def audio_codec
    $1 if raw_info =~ /Audio: ([^\n,]*)/
  rescue
    nil
  end

  def resized_size_of_video(multiple=2)
    # Use fancy mathematics to keep videos from being stretched into 320x240
    width  = 320
    height = width.to_f / resolution[0] * resolution[1]

    # Ensure that the dimensions are multiples of 2 (so ffmpeg doesn't whine),
    # or another given multiple
    height = height.nearest_multiple_of(multiple)

    size   = [width, height].join("x")
  rescue
    "320x240"
  end

  def screenshot_time(dur=0)
    time = dur / 3
    h = time / 60 * 60
    m = (time - h * 60 * 60) / 60
    s = time - h * 60 * 60 - m * 60
    
    [h.to_i, m.to_i, s.to_i].join(":")
  end

end

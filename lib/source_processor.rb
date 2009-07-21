require 'source_info'

class SourceProcessor
  def initialize(source, logger)
    @source = source
    @logger = logger
  end

  attr_reader :source, :logger # reference to the source we're updating
  attr_accessor :info # object that parses raw ffmpeg output
  attr_accessor :tmp_filename # location where curl downloads the source initially

  class << self;
    # Runs the different source processing mechanisms, in order
    # The only ordering that matters is #download_file has to happen first
    def process_source(source, logger=nil)
      logger.info ""
      logger.info "Working on source #{source.id}"
      logger.info Time.now.to_formatted_s(:info)

      processor = self.new(source, logger)

      raise "No url for source #{source.id}!" if source.url.blank?

      processor.process!
    rescue
      logger.fatal $!
      logger.fatal $!.backtrace.join("\n")
      processor.update_source
    ensure
      processor.remove_tmp_files
    end
  end

  def process!
    get_http_info

    log_time { download_file }
    
    get_video_info
    
    log_time { generate_torrent }
    
    unless lacking_video?
      take_screen_shot
      
      # Create flv
      log_time { encode_preview_video }
      # XXX: we are going to wait for a while to turn this on
      # log_time { encode_random_video(source, info) }
      
    end
    
    # Updates database with info taken from the video
    update_source
  end

  def log_time
    t0 = Time.now
    yield
    logger.info "  * Took #{(Time.now - t0).to_i.to_duration}"
  end

  def download_file
    logger.info "Downloading #{source.url}"
    
    self.remove_tmp_files
    `mkdir -p /tmp/source/#{source.id}`
    @curl_info = `cd /tmp/source/#{source.id} && curl -I -L '#{source.url.gsub("'", "")}'`
    @curl_info << `cd /tmp/source/#{source.id} && curl -L -O '#{source.url.gsub("'", "")}' 2>&1`
    source.update_attributes(:downloaded_at => Time.now, :curl_info => @curl_info)
    self.tmp_filename  = `cd /tmp/source/#{source.id} && ls | tail -n 1`.strip
    raise "File not downloaded" if self.tmp_filename.blank?
    logger.info "Saved original to #{self.tmp_file}"
  end

  def get_http_info
    curl_output = `curl -L -I '#{source.url.gsub("'", "")}'`
    headers = curl_output.split(/[\r\n]/)
    content_types = headers.select{|h| h =~ /^Content-Type/}
    @content_type_from_http = content_types.empty? ? '' : content_types.last.split(": ").last rescue nil
    @file_name_from_http = filename_from_http_content_disposition(headers)
    @file_name_from_http ||= filename_from_http_location(headers)
  end

  def filename_from_http_content_disposition(headers)
    disposition = headers.select{|h| h =~ /^Content-Disposition/}.last || ""
    disposition =~ /filename=\"([^\"]+)\"/
    $1
  rescue
    nil
  end

  def filename_from_http_location(headers)
    location = headers.select{|h| h =~ /^Location/}.last || ""
    File.basename(location.split(": ").last)
  rescue
    nil
  end

  def get_video_info
    raise "Source file not present: #{self.tmp_file}" unless File.exist?(self.tmp_file)

    logger.info "Getting video info for #{self.tmp_file}"
    
    raw_info = `ffmpeg -i #{self.tmp_file} 2>&1`
    @info = SourceInfo.new(raw_info, source)
    @info.file_size = `ls -l #{self.tmp_file} | awk '{print $5}'`.strip.to_i
    @info.file_name = @file_name_from_http || self.tmp_filename
    @info.sha1hash  = `sha1 #{self.tmp_file} | cut -f1 -d" "`.strip
    if(`uname`.chomp == "Darwin")
      @info.content_type = `file -Ib '#{self.tmp_file}'`.chomp
    else
      @info.content_type = `file -ib '#{self.tmp_file}'`.chomp
    end
    
    logger.info "Got: #{@info.inspect}"
  end

  # ffmpeg -i diggnation--0184--clipshow2008--small.h264.mp4 -vcodec libx264 -acodec libfaac -b 256k -r 20 -ab 64k -ar 22050 -s 320x240 -t 30 a.h264.mp4
  def encode_video(field, start_offset = 0)
    raise "No file to encode from" unless File.exist?(self.tmp_file)

    logger.info "FFMPEG'ing to #{encoded_tmp_file}"
    length            = "00:05:00"
    video_bitrate     = 256.kilobytes
    audio_bitrate     = 64.kilobytes # 96.kilobytes
    video_frame_rate  = 20
    audio_sample_rate = 44100
    size              = info.resized_size_of_video
    start             = info.screenshot_time(start_offset || 0)

    options = {
      :i  => tmp_file,          # input
      :ac => 1,                 # audio channels
      :b  => video_bitrate,     # video bitrate
      :r  => video_frame_rate,  # video framerate
      # :ab => audio_bitrate,    # audio bitrate (had some troubles with this earlier)
      :ar => audio_sample_rate, # audio sample rate
      :s  => size,              # resolution
      :ss => start,             # start time
      :t  => length             # length
    }

    case field
    when :preview 
      filename = encoded_tmp_file(:mp4)
      options.merge!(
        :f      => :mp4,         # format (container)
        :vcodec => :libx264,     # video codec
        :acodec => :libfaac,     # audio codec
        :crf    => 22            # for h264 processing
      )
    when :ogg_preview
      filename = encoded_tmp_file(:ogg)
      options.merge!(
        :b      => 512.kilobytes,
        :f      => :ogg,
        :vcodec => :libtheora,
        :acodec => :libvorbis,
        :s      => info.resized_size_of_video(16), # FF3.5 needs OGG w/resolution in mult. of 16
        :ac     => 2              # due to a bug in ffmpeg?
      )
    end

    options = options.map {|k,v| ["-#{k}", v] }.flatten.join(" ")

    "ffmpeg -y #{options} #{filename}".tap { |cmd| logger.info(cmd) and `#{cmd}` }

    if File.exists?(filename)
      source.attachment_for(field).assign(File.open(filename))
      source.save!
    end
  end

  def encode_preview_video
    logger.info "Encoding preview videos"
    encode_video(:preview)
    encode_video(:ogg_preview)
  end

  def encode_random_video
    start_offset = info.duration - 5.minutes
    
    if start_offset > 0
      encode_video(:random_clip, start_offset)
    end
  end

  def lacking_video?
    info.resolution.compact.blank? || info.video_codec.nil? || info.duration.nil?
  end

  def take_screen_shot
    logger.info "Screenshotting"
    
    begin
      size = info.resized_size_of_video
    
      t = info.screenshot_time(info.duration)
      screenshot_cmd = "ffmpeg -y -i #{self.tmp_file} -vframes 1 -s #{size} -ss #{t} -an -vcodec jpg -f rawvideo #{self.screenshot_tmp_file}"
      logger.info screenshot_cmd
      `#{screenshot_cmd}`
    
      if File.exists?(self.screenshot_tmp_file)
        logger.info "Generated screenshot #{self.screenshot_tmp_file}"
        source.attachment_for(:screenshot).assign(File.open(self.screenshot_tmp_file))
        source.save!
      end
    rescue Exception => e
      logger.fatal $!
      logger.fatal $!.backtrace.join("\n")
    end
  end
  
  def generate_torrent
    raise "Source file does not exist" unless File.exist?(self.tmp_file)

    torrent_cmd = "mktorrent -a http://tracker.limecast.com/announce -o #{self.torrent_tmp_file} -w #{source.url} #{self.tmp_file} 2>&1"
    logger.info torrent_cmd
    torrent_info = `#{torrent_cmd}`
    
    source.update_attribute(:torrent_info, torrent_info)

    if File.exists?(self.torrent_tmp_file)
      logger.info "Generated torrent #{self.torrent_tmp_file}"
      source.attachment_for(:torrent).assign(File.open(self.torrent_tmp_file))
      source.save!
    end
  end

  def update_source
    logger.info "Updating source"
    begin
      source.update_attribute( # do this first in case there is an issue updating the other data
        :ability, ABILITY
      )  
      if info
        source.episode.update_attributes(
          :duration => info.duration
        )
        source.podcast.update_attributes(
          :format   => info.file_format || info.video_codec || info.audio_codec,
          :bitrate  => info.bitrate
        )
        source.update_attributes(
          :format               => info.file_format || info.video_codec || info.audio_codec,
          :sha1hash             => info.sha1hash,
          :hashed_at            => Time.now,
          :height               => info.resolution[1],
          :width                => info.resolution[0],
          :framerate            => info.framerate,
          :size_from_disk       => info.file_size,
          :file_name            => info.file_name,
          :extension_from_disk  => self.disk_extension,
          :duration_from_ffmpeg => info.duration,
          :content_type_from_http => @content_type_from_http,
          :content_type_from_disk => info.content_type,
          :bitrate_from_feed    => info.bitrate
        )
      else
        logger.fatal "No info variable available."
      end
    rescue Exception => e
      logger.fatal $!
      logger.fatal $!.backtrace.join("\n")
    end
  end

  def torrent_tmp_file
    "#{tmp_file}.torrent" if tmp_file
  end

  def screenshot_tmp_file
    "#{tmp_file}_screenshot.jpg" if tmp_file
  end
  
  def encoded_tmp_file(ext=nil)
    "#{tmp_file}_encoded#{'.' + ext.to_s if ext}" if tmp_file
  end

  def tmp_file
    "/tmp/source/#{source.id}/#{tmp_filename}" if tmp_filename
  end

  def disk_extension
    filename_array = tmp_filename.split(".")

    if filename_array.size > 0
      $1 if filename_array.last =~ /([a-z0-9]*)/i rescue ""
    else
      ''
    end
  end

  def remove_tmp_files
    `rm -Rf /tmp/source/#{source.id}`
  end
end

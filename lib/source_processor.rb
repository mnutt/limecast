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

      processor = self.new(source, logger)

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
    t0 = Time.now
      download_file
    logger.info "  * Took #{(Time.now - t0).to_i.to_duration}"
    
    get_video_info
    
    t0 = Time.now
      generate_torrent
    logger.info "  * Took #{(Time.now - t0).to_i.to_duration}"
    
    unless lacking_video?
      take_screen_shot
      
      # Create flv
      t0 = Time.now
        encode_preview_video
      logger.info "  * Took #{(Time.now - t0).to_i.to_duration}"
      # XXX: we are going to wait for a while to turn this on
      # encode_random_video(source, info)
    end
    
    # Updates database with info taken from the video
    update_source
  end

  def download_file
    logger.info "Downloading #{source.url}"
    
    self.remove_tmp_files
    `mkdir -p /tmp/source/#{source.id}`
    @curl_info = `cd /tmp/source/#{source.id} && curl -L -O '#{source.url.gsub("'", "")}' 2>&1`
    self.tmp_filename  = `cd /tmp/source/#{source.id} && ls | tail -n 1`.strip
    raise "File not downloaded" if self.tmp_filename.blank?
    logger.info "Saved original to #{self.tmp_file}"
    
    source.update_attributes(:downloaded_at => Time.now, :curl_info => @curl_info)
  end

  def get_video_info
    raise "Source file not present: #{self.tmp_file}" unless File.exist?(self.tmp_file)

    logger.info "Getting video info for #{self.tmp_file}"
    
    raw_info = `ffmpeg -i #{self.tmp_file} 2>&1`
    @info = SourceInfo.new(raw_info, source)
    @info.file_size = `ls -l #{self.tmp_file} | awk '{print $5}'`.strip.to_i
    @info.file_name = self.tmp_file
    @info.sha1hash  = `sha1 #{self.tmp_file} | cut -f1 -d" "`.strip
    
    logger.info "Got: #{@info.inspect}"
  end

  # ffmpeg -i diggnation--0184--clipshow2008--small.h264.mp4 -vcodec libx264 -acodec libfaac -b 256k -r 20 -ab 64k -ar 22050 -s 320x240 -t 30 a.h264.mp4
  def encode_video(field, start_offset=0)
    raise "No file to encode from" unless File.exist?(self.tmp_file)

    logger.info "FLV'ing to #{self.encoded_tmp_file}"
    length            = "00:05:00"
    video_bitrate     = 512.kilobytes
    audio_bitrate     = 96.kilobytes
    video_frame_rate  = 20
    audio_sample_rate = 44100
    
    size = info.resized_size_of_video
    
    options = {
      :i  => self.tmp_file,   :f  => :flv,
      :ac => 1,                 :b  => video_bitrate,
      :r  => video_frame_rate,  :ab => audio_bitrate,
      :ar => audio_sample_rate, :t  => length,
      :s  => size,              :ss => info.screenshot_time(start_offset || 0)
    }.map {|k,v| ["-#{k}", v] }.flatten.join(" ")
    
    encode_cmd = "ffmpeg -y #{options} #{self.encoded_tmp_file}"
    logger.info encode_cmd
    `#{encode_cmd}`
    
    if File.exists?(self.encoded_tmp_file)
      source.attachment_for(field).assign(File.open(self.encoded_tmp_file))
      source.save!
    end
  end

  def encode_preview_video
    logger.info "Encoding preview video"
    encode_video(:preview)
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
    
    size = info.resized_size_of_video
    
    t = info.screenshot_time(info.duration)
    screenshot_cmd = "ffmpeg -y -i #{self.tmp_file} -vframes 1 -s #{size} -ss #{t} -an -vcodec png -f rawvideo #{self.screenshot_tmp_file}"
    logger.info screenshot_cmd
    `#{screenshot_cmd}`
    
    if File.exists?(self.screenshot_tmp_file)
      logger.info "Generated screenshot #{self.screenshot_tmp_file}"
      source.attachment_for(:screenshot).assign(File.open(self.screenshot_tmp_file))
      source.save!
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
    source.episode.update_attributes(
      :duration => info.duration
    )
    source.feed.update_attributes(
      :format   => info.file_format || info.video_codec || info.audio_codec,
      :bitrate  => info.bitrate
    )
    source.update_attributes(
      :ability              => ABILITY,
      :format               => info.file_format || info.video_codec || info.audio_codec,
      :sha1hash             => info.sha1hash,
      :hashed_at            => Time.now,
      :height               => info.resolution[1],
      :width                => info.resolution[0],
      :framerate            => info.framerate,
      :size_from_disk       => info.file_size,
      :file_name            => info.file_name,
      :duration_from_ffmpeg => info.duration
    )
  end

  def torrent_tmp_file
    "#{tmp_file}.torrent" if tmp_file
  end

  def screenshot_tmp_file
    "#{tmp_file}_screenshot.png" if tmp_file
  end
  
  def encoded_tmp_file
    "#{tmp_file}_encoded" if tmp_file
  end

  def tmp_file
    "/tmp/source/#{source.id}/#{tmp_filename}" if tmp_filename
  end

  def remove_tmp_files
    `rm -Rf /tmp/source/#{source.id}`
  end
end

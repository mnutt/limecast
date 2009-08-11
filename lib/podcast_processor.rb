class PodcastProcessor
  class BannedFeedException     < Exception; def message; "This feed site is not allowed." end end
  class InvalidAddressException < Exception; def message; "That's not a web address." end end
  class NoEnclosureException    < Exception; def message; "That's a text RSS feed, not an audio or video podcast." end end
  class DuplicateFeedExeption   < Exception; def message; "This feed has already been added to the system." end end
  class InvalidFeedException    < Exception; def message; "This feed is not supported." end end

  # def create
  #   @feed = Feed.find_by_url(params[:feed][:url])
  #   if @feed
  #     @feed.update_attribute(:state, "pending") if @feed.failed? || @feed.blacklisted?
  #     @feed.send_later(:refresh)
  #   else
  #     # XXX: Can i set this up where current_user is some kind of mock user when the person is not logged in so that the feed automatically gets added to the session instead of the db?
  #     @feed = Feed.create(:url => params[:feed][:url], :finder => current_user)
  #   end

  attr_accessor :podcast, :logger

  def self.process(queued_podcast, logger=nil)
    self.new(queued_podcast, logger).process
  end

  def self.process_archives(queued_podcast, logger=nil)
    self.new(queued_podcast, logger).process_archives
  end

  def initialize(queued_podcast, logger)
    @qp = queued_podcast
    @logger = logger || @logger = Logger.new(RAILS_ROOT + "/log/update_podcasts.log")
  end
  
  def process
    ActiveRecord::Base.transaction do
      @podcast = @qp.podcast || Podcast.new(:url => @qp.url)
      @podcast.valid?

      if invalid_address?
        @state = "invalid_address"
        raise InvalidAddressException
      end
      if banned?
        @state = "blacklisted"
        raise BannedFeedException
      end

      @content = fetch
      @rpodcast_feed = RPodcast::Feed.new(@content)

      if invalid_xml?
        @state = "invalid_xml"
        raise InvalidFeedException
      end
      if no_enclosure?
        @state = "no_enclosure"
        raise NoEnclosureException
      end

      @rpodcast_feed.parse

      if no_episodes?
        raise InvalidFeedException
      end

      update_podcast!
      update_tags!

      if duplicate_feed?
        @state = "duplicate"
        raise DuplicateFeedExeption
      end

      update_episodes!
    end

  rescue Exception
    exception = $!

    if ActiveRecord::RecordInvalid === exception
      @state = "invalid_record"
    end

    log_failed(exception)
    PodcastMailer.deliver_failed_queued_podcast(@qp, exception)
    # We saved the duplicate feed id to a variable so that we could point this feed to the correct one
    @qp.update_attributes(:state => @state || 'failed', :podcast_id => @duplicate_podcast_id, :error => exception.class.to_s)
  end

  def process_archives
    @podcast = @qp.podcast || Podcast.new(:url => @qp.url)
    
    begin
      update_archives!
    rescue => exception
      if ActiveRecord::RecordInvalid === exception
        @state = "invalid_record"
      end

      log_failed(exception)
      PodcastMailer.deliver_failed_queued_podcast(@qp, exception)
      # We saved the duplicate feed id to a variable so that we could point this feed to the correct one
      @qp.update_attributes(:state => @state || 'failed', :podcast_id => @duplicate_podcast_id, :error => exception.class.to_s)
    end
  end

  def log_failed(exception)
    logger.fatal exception
    logger.fatal exception.backtrace.join("\n")
    stored_exception = {
      :podcast => @qp.url,
      :klass => exception.class.to_s,
      :message => exception.to_s,
      :backtrace => exception.backtrace
    }
    File.open("#{RAILS_ROOT}/log/last_add_failed.yml", "w") do |f|
      f.write(YAML::dump(stored_exception))
    end
  end

  # By making the fetch method return the XML instead of saving it to an ivar,
  # we can mock it easier.
  def fetch
    Timeout::timeout(15) do
      OpenURI::open_uri(@qp.url, "User-Agent" => "LimeCast/0.1") do |f|
        f.read
      end
    end
  rescue NoMethodError
    @state = "invalid_address"
    raise InvalidAddressException
  end

  def update_podcast!
    @podcast.attributes = {
      :finder      => @qp.user,
      :bitrate     => @rpodcast_feed.bitrate.nearest_multiple_of(64),
      :generator   => @rpodcast_feed.generator,
      :ability     => ABILITY,
      :xml         => @content,
      :author_email => @rpodcast_feed.owner_email.to_s.gsub(/\(.*\)/, '').strip,
      :author_name  => @rpodcast_feed.owner_name,
      :xml_title   => @rpodcast_feed.title.to_s.strip,
      :subtitle    => @rpodcast_feed.subtitle.to_s.strip,
      :description => @rpodcast_feed.summary.to_s.strip,
      :language    => @rpodcast_feed.language,
      :site        => @rpodcast_feed.link,
      :state       => "parsed"
    }
    @podcast.download_logo(@rpodcast_feed.image) unless @rpodcast_feed.image.nil?
    @podcast.save!

    @qp.update_attributes(
      :podcast_id => @podcast.id,
      :error      => '',
      :state      => 'parsed'
    )
  end

  def update_tags!
    tags = @rpodcast_feed.categories.compact.map { |t| Tag.tagize(t) }
    tags << "hd" if @rpodcast_feed.hd?
    tags << "video" if @rpodcast_feed.video?
    tags << "audio" if @rpodcast_feed.audio?
    tags << "torrent" if @rpodcast_feed.torrent?
    tags << "creativecommons" if @rpodcast_feed.creative_commons?
    tags << "explicit" if @rpodcast_feed.explicit?
    @podcast.tag_string = tags.join(" "), (@podcast.author || @qp).user
  end

  def update_episodes!
    @podcast.episodes.update_all :archived => true

    @rpodcast_feed.episodes.each do |e|
      episode = @podcast.episodes.find_or_initialize_by_title(e.title.to_s.strip)

      ss = ([e.enclosure] + e.media_contents)

      # Skip if this might be a duplicate episode (where title changed)
      next if episode.new_record? &&
              @podcast.sources.exists?(["size_from_xml > 0 AND size_from_xml IN (?)", ss.map(&:size)]) 

      episode.attributes = { :archived     => false,
                             :summary      => e.summary.to_s.strip,
                             :published_at => e.published_at,
                             :title        => e.title.to_s.strip,
                             :subtitle     => e.subtitle.to_s.strip,
                             :duration     => e.duration,
                             :xml          => e.raw_xml,
                             :guid         => e.guid }
      if episode.save
        ss.each do |s|
          source = @podcast.sources(true).find_or_initialize_by_url_and_episode_id(s.url.to_s.strip, episode.id)

          source.attributes = { :duration_from_feed     => (s.duration.to_i == 0 ? e.duration : s.duration),
                                :bitrate_from_feed      => (s.bitrate.to_i == 0 ? e.bitrate : s.bitrate).nearest_multiple_of(64),
                                :episode_id             => episode.id,
                                :published_at           => e.published_at,
                                :format                 => s.format.to_s,
                                :content_type_from_feed => s.content_type,
                                :extension_from_feed    => s.extension,
                                :size_from_xml          => s.size,
                                :url                    => s.url.to_s.strip }
          source.save
        end
      end
    end
    

    # Update the daily orders
    @podcast.episodes.all(:order => "published_at ASC").group_by(&:clean_url).each do |day, episodes|
      episodes.inject(1) do |order, ep|
        ep.update_attribute(:daily_order, order)
        order += 1 
      end
    end
  end
  
   # Ensure archived xml is reparsed (eg in case code changes)
  def update_archives!
    @podcast.episodes.all(:conditions => {:archived => true}).each do |episode|
      doc = Hpricot.XML(episode.xml.to_s)
      e = RPodcast::Episode.new(doc) 
    
      unless e.guid.blank? && e.title.blank?
        episode.attributes = { :summary      => e.summary.to_s.strip,
                               :published_at => e.published_at,
                               :title        => e.title.to_s.strip,
                               :subtitle     => e.subtitle.to_s.strip,
                               :duration     => e.duration,
                               :xml          => e.raw_xml,
                               :guid         => e.guid }
        if episode.save
          ([e.enclosure] + e.media_contents).each do |s|
            source = episode.sources(true).find_or_initialize_by_url(s.url.to_s.strip)
            source.attributes = { :duration_from_feed     => (s.duration.to_i == 0 ? e.duration : s.duration),
                                  :bitrate_from_feed      => (s.bitrate.to_i == 0 ? e.bitrate : s.bitrate).nearest_multiple_of(64),
                                  :published_at           => e.published_at,
                                  :format                 => s.format.to_s,
                                  :content_type_from_feed => s.content_type,
                                  :extension_from_feed    => s.extension,
                                  :size_from_xml          => s.size,
                                  :url                    => s.url.to_s.strip }
            source.save
          end
        end

        # Destroy if url is not present
        episode.sources(true).each { |s| s.destroy if s.url.blank? }
      end
    end
  end


  protected

  def invalid_address?
    !@qp.url =~ %r{^([^/]*//)?([^/]+)}
  end

  def banned?
    !!(Blacklist.find_by_domain($2) if @qp.url =~ %r{^([^/]*//)?([^/]+)})
  end

  def no_enclosure?
    !@rpodcast_feed.has_enclosure? && !@rpodcast_feed.has_media_content?
  end

  def invalid_xml?
    !@rpodcast_feed.valid?
  end

  def duplicate_feed?
    @rpodcast_feed.episodes.each do |e|
      # XXX Refactor?
      episode = @podcast.episodes.find_by_guid(e.guid) || Episode.new(:podcast => @podcast)
      episode.sources.each do |source|
        if source.podcast.id != @podcast.id
          @duplicate_podcast_id = source.podcast_id
          return true
        end
      end
    end

    false
  end

  def no_episodes?
    @rpodcast_feed.episodes.empty?
  end
end


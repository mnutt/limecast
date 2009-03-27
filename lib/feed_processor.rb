class FeedProcessor
  # def create
  #   @feed = Feed.find_by_url(params[:feed][:url])
  #   if @feed
  #     @feed.update_attribute(:state, "pending") if @feed.failed? || @feed.blacklisted?
  #     @feed.send_later(:refresh)
  #   else
  #     # XXX: Can i set this up where current_user is some kind of mock user when the person is not logged in so that the feed automatically gets added to the session instead of the db?
  #     @feed = Feed.create(:url => params[:feed][:url], :finder => current_user)
  #   end

  attr_accessor :feed

  def self.process(url)
    fp = self.new(url)

    fp.feed
  end

  def initialize(url)
    url = clean_url(url)

    @feed = Feed.find_by_url(url)
    if @feed.nil?
      @feed = Feed.create(:url => url)
    elsif @feed.blacklisted?
      return
    elsif @feed.failed?
      @feed.update_attribute(:state, "pending")
    end

    refresh
  end

  def clean_url(url)
    url.gsub!(%r{^feed://}, "http://")
    url.strip!
    url = 'http://' + url.to_s unless url.to_s =~ %r{://}

    url
  end

  def refresh
    raise Feed::InvalidAddressException unless @feed.url =~ %r{^([^/]*//)?([^/]+)}
    raise Feed::BannedFeedException if Blacklist.find_by_domain($2)

    @content = fetch
    parse
    update_podcast!
    update_tags!
    update_episodes!
    update_feed!

  rescue Exception
    exception = $!
    log_failed(exception)
    PodcastMailer.deliver_failed_feed(@feed, exception)
    @feed.update_attributes(:state => 'failed', :error => exception.class.to_s)
  end

  def log_failed(exception)
    stored_exception = {
      :feed => @feed.url,
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
    xml = ""
    Timeout::timeout(15) do
      OpenURI::open_uri(@feed.url, "User-Agent" => "LimeCast/0.1") do |f|
        xml = f.read
      end
    end

    xml
  rescue NoMethodError
    raise Feed::InvalidAddressException
  end

  def parse
    begin
      @rpodcast_feed = RPodcast::Feed.new(@content)

      raise Feed::InvalidFeedException if @rpodcast_feed.episodes.empty?
    rescue RPodcast::NoEnclosureError
      raise Feed::NoEnclosureException
    end
  end

  def similar_to_podcast?(podcast)
    return true if podcast.new_record?
    # XXX: This is a problem we are looking at the domain name to see if we already have the podcast
    # this means that we think "http://revision3.com/coop/feed/xvid-large" and ""http://revision3.com/hak5/feed/xvid-large" are the same thing
    return false unless URI::parse(@rpodcast_feed.link).host == URI::parse(podcast.site).host
    true
  end

  def update_podcast!
    @feed.podcast ||= Podcast.find_by_site(@rpodcast_feed.link) || Podcast.new
    raise Feed::FeedDoesNotMatchPodcast unless self.similar_to_podcast?(@feed.podcast)

    @feed.podcast.download_logo(@rpodcast_feed.image) unless @rpodcast_feed.image.nil?
    @feed.podcast.update_attributes!(
      :original_title => @rpodcast_feed.title,
      :description    => @rpodcast_feed.summary,
      :language       => @rpodcast_feed.language,
      :owner_email    => @rpodcast_feed.owner_email,
      :owner_name     => @rpodcast_feed.owner_name,
      :site           => @rpodcast_feed.link
    )
    @feed.podcast.notify_users
  rescue RPodcast::NoEnclosureError
    raise Feed::NoEnclosureException
  end

  def update_tags!
    @feed.podcast.tag_string = "hd" if @rpodcast_feed.hd?
    @feed.podcast.tag_string = "video" if @rpodcast_feed.video?
    @feed.podcast.tag_string = "audio" if @rpodcast_feed.audio?
    @feed.podcast.tag_string = "torrent" if @rpodcast_feed.torrent?
    @feed.podcast.tag_string = "creativecommons" if @rpodcast_feed.creative_commons?
    @feed.podcast.tag_string = "explicit" if @rpodcast_feed.explicit?

    @feed.podcast.tag_string = @rpodcast_feed.categories.map {|t| Tag.tagize(t) }.join(" ")
  end

  def update_episodes!
    @feed.sources.update_all :archived => true

    @rpodcast_feed.episodes.each do |e|
      # XXX: Definitely need to figure out something better for this.
      episode = @feed.podcast.episodes.find_by_title(e.title) || @feed.podcast.episodes.new
      source = Source.find_by_guid_and_episode_id(e.guid, episode.id) || Source.new(:feed => @feed)

      # The feed is a duplicate if the source found matches a source from another (older) feed.
      raise Feed::DuplicateFeedExeption if source.feed != @feed && source.created_at < @feed.created_at

      episode.update_attributes(
        :summary      => e.summary,
        :published_at => e.published_at,
        :title        => e.title,
        :duration     => e.duration
      )
      source.update_attributes(
        :guid       => e.guid,
        :format     => e.enclosure.format.to_s,
        :type       => e.enclosure.content_type,
        :size       => e.enclosure.size,
        :url        => e.enclosure.url,
        :episode_id => episode.id,
        :xml        => e.raw_xml,
        :archived   => false
      )
    end
  end

  def update_feed!
    @feed.update_attributes(
      :bitrate => @rpodcast_feed.bitrate.nearest_multiple_of(64),
      :ability => ABILITY,
      :state   => 'parsed',
      :xml     => @content
    )
  end

end


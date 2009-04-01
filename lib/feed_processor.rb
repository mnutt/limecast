class FeedProcessor
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

  attr_accessor :feed

  def initialize(queued_feed)
    @qf   = queued_feed
    @feed = queued_feed.feed || Feed.create(:url => @qf.url)

    process
  end

  def process
    ActiveRecord::Base.transaction do
      raise InvalidAddressException if invalid_address?
      raise BannedFeedException     if banned?

      @content = fetch
      @rpodcast_feed = RPodcast::Feed.new(@content)

      raise InvalidFeedException if invalid_xml?
      raise NoEnclosureException if no_enclosure?

      @rpodcast_feed.parse

      raise InvalidFeedException if no_episodes?

      update_podcast!
      update_tags!

      raise DuplicateFeedExeption if duplicate_feed?

      update_episodes!
      update_feed!
    end

  rescue Exception
    exception = $!
    log_failed(exception)
    PodcastMailer.deliver_failed_feed(@feed, exception)
    @qf.update_attributes(:state => 'failed', :error => exception.class.to_s)
  end

  def log_failed(exception)
    stored_exception = {
      :feed => @qf.url,
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
      OpenURI::open_uri(@qf.url, "User-Agent" => "LimeCast/0.1") do |f|
        f.read
      end
    end
  rescue NoMethodError
    raise InvalidAddressException
  end

  def update_podcast!
    @feed.podcast = Podcast.find_or_initialize_by_site(@rpodcast_feed.link) if @feed.podcast.nil?

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
  end

  def update_tags!
    tags = @rpodcast_feed.categories.map { |t| Tag.tagize(t) }
    tags << "hd" if @rpodcast_feed.hd?
    tags << "video" if @rpodcast_feed.video?
    tags << "audio" if @rpodcast_feed.audio?
    tags << "torrent" if @rpodcast_feed.torrent?
    tags << "creativecommons" if @rpodcast_feed.creative_commons?
    tags << "explicit" if @rpodcast_feed.explicit?

    @feed.podcast.tag_string = tags.join(" "), (@feed.podcast.owner || @qf.finder)
  end

  def update_episodes!
    @feed.sources.update_all :archived => true

    @rpodcast_feed.episodes.each do |e|
      # XXX: Definitely need to figure out something better for this.
      episode = @feed.podcast.episodes.find_or_initialize_by_title(e.title)
      source = @feed.sources.find_or_initialize_by_guid_and_episode_id(e.guid, episode.id)

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
      :finder_id => @qf.user_id,
      :ability => ABILITY,
      :xml     => @content
    )
    @qf.update_attributes(
      :feed_id => @feed.id,
      :error   => '',
      :state   => 'parsed'
    )
  end

  protected

  def invalid_address?
    !@qf.url =~ %r{^([^/]*//)?([^/]+)}
  end

  def banned?
    !!(Blacklist.find_by_domain($2) if @qf.url =~ %r{^([^/]*//)?([^/]+)})
  end

  def no_enclosure?
    !@rpodcast_feed.has_enclosure?
  end

  def invalid_xml?
    !@rpodcast_feed.valid?
  end

  def duplicate_feed?
    @rpodcast_feed.episodes.each do |e|
      episode = @feed.podcast.episodes.find_by_title(e.title) || @feed.podcast.episodes.new
      source = Source.find_by_guid_and_episode_id(e.guid, episode.id) || Source.new(:feed => @feed)
    
      return true if source.feed != @feed
    end

    false
  end

  def no_episodes?
    @rpodcast_feed.episodes.empty?
  end
end


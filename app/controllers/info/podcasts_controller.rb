class Info::PodcastsController < InfoController
  def show
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
  end

  def add
    @exception = YAML.load_file("#{RAILS_ROOT}/log/last_add_failed.yml")
  end

  def hash
    @sources = Source.find(:all, :conditions => ["hashed_at > ?", 3.days.ago],
                           :limit => 40,
                           :order => "hashed_at DESC")
    @sources_count = Source.approved.count
    @unhashed_count = Source.stale.approved.count
    @unapproved_count = Source.count - Source.approved.count
    @hashed_count = @sources_count - @unhashed_count
    @percentage = (@hashed_count.to_f / @sources_count.to_f * 100).to_i
    @last_day = Source.count(:conditions => ["hashed_at > ?", 1.day.ago])

    @probably_next_source = Source.stale.find(:first, :order => "id DESC")
    @hashing_tail = `tail -n 40 #{RAILS_ROOT}/log/update_sources.log`
  end
end


class Info::FeedsController < InfoController
  def show
    @feed = Feed.find(params[:id])
    @feed_xml = @feed.diagnostic_xml

    render :layout => 'info'
  end

  def add
    @exception = YAML.load_file("#{RAILS_ROOT}/log/last_add_failed.yml")
    render :layout => 'info'
  end

  def hash
    @sources = Source.find(:all, :conditions => ["hashed_at > ?", 3.days.ago],
                           :limit => 40,
                           :order => "hashed_at DESC")
    @sources_count = Source.count
    @unhashed_count = Source.stale.count
    @hashed_count = @sources_count - @unhashed_count
    @percentage = (@hashed_count.to_f / @sources_count.to_f * 100).to_i
    @last_day = Source.count(:conditions => ["hashed_at > ?", 1.day.ago])

    @probably_next_source = Source.stale.find(:first, :order => "id DESC")
    @hashing_tail = `tail -n 40 #{RAILS_ROOT}/log/update_sources.log`

    render :layout => 'info'
  end
end

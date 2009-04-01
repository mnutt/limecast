class FeedsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :status

  def new
    @feed = Feed.new
  end

  def show
    @feed = Feed.find params[:id]

    render :xml => @feed.as(params[:type])
  end

  def create
    @queued_feed = QueuedFeed.add_to_queue(params[:feed][:url])

    remember_unclaimed_record(@queued_feed)

    render :nothing => true
  end

  def status
    @queued_feed = QueuedFeed.find_by_dirty_url(params[:feed][:url])
    @feed        = @queued_feed.feed if @queued_feed
    @podcast     = @feed.podcast if @queued_feed && @feed

    # See http://wiki.limewire.org/index.php?title=LimeCast_Add#Messages
    # Unexpected errors
    if @queued_feed.nil?
      render :partial => 'status_error'
    # Successes
    elsif @podcast && @queued_feed.parsed? && queued_feed_created_just_now_by_user?(@queued_feed)
      render :partial => 'status_added'
    # Expected errors
    elsif @queued_feed.failed? || @queued_feed.blacklisted? || @podcast && @queued_feed.parsed?
      render :partial => 'status_failed'
    # Progress
    elsif @queued_feed.pending?
      render :partial => 'status_loading'
    # Really unexpected errors
    else
      render :partial => 'status_error'
    end
  end

  def update
    @feed = Feed.find params[:id]
    authorize_write @feed

    respond_to do |format|
      format.js do
        if @feed.update_attributes(params[:feed])
          render :nothing => true, :status => 200
        else
          render :nothing => true, :status => 500
        end
      end
    end
  end

  def destroy
    @feed = Feed.find params[:id]
    @podcast = @feed.podcast
    authorize_write @feed

    respond_to do |format|
      format.js do
        if @feed.destroy
          render :nothing => true, :status => 200
        else
          render :nothing => true, :status => 500
        end
      end
      format.html do
        @feed.destroy
        redirect_to podcast_url(@podcast)
      end
    end
  end

  def info
    @feed = Feed.find(params[:id])
    @feed_xml = @feed.diagnostic_xml

    render :layout => 'info'
  end

  def add_info
    @exception = YAML.load_file("#{RAILS_ROOT}/log/last_add_failed.yml")
    render :layout => 'info'
  end

  def hash_info
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

  protected

    def queued_feed_in_session?(queued_feed)
      # XXX: Fix to mesh with tiegs code
      (session[:queued_feeds] and session[:queued_feeds].include?(queued_feed.id))
    end

    def queued_feed_created_by_user?(queued_feed)
      queued_feed_in_session?(queued_feed) or queued_feed.user == current_user
    end

    def queued_feed_created_just_now_by_user?(queued_feed)
      queued_feed_created_by_user?(queued_feed) && queued_feed.created_at > 2.minutes.ago
    end
end

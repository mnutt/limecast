class PodcastsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :status
  before_filter :login_required, :only => [:edit, :update, :destroy]

  # GET /all.xml
  def index
    @podcasts = Podcast.sorted
    respond_to(:html, :xml)
  end

  # GET /popular.xml
  def popular
    @podcasts = Podcast.popular.paginate(
      :page => (params[:page] || 1),
      :per_page => params[:limit] || 10
    )

    respond_to do |format|
      format.html
      format.xml { render :index }
    end
  end
  
  # GET /recently_updated.xml
  def recently_updated
    @podcasts = Episode.sorted.paginate(
      :per_page => 10, 
      :page => 1, 
      :group => :podcast_id
    ).map(&:podcast)

    respond_to do |format|
      format.xml { render :index }
    end
  end

  # GET /add
  def new
    @podcast = Podcast.new
  end

  # GET /:podcast_slug
  def show
    @podcast ||= Podcast.find_by_slug(params[:podcast_slug])

    @newest_episode = @podcast.newest_episode

    @episodes = @podcast.episodes.all(:include => :sources, :limit => 5, :order => "published_at DESC, date_title DESC")
    @related  = @podcast.related_podcasts
    @reviews  = @podcast.reviews.claimed.all
    @review   = Review.new(:episode => @newest_episode)
  end

  # GET /plain_feeds/:id.xml
  # GET /torrent_feeds/:id.xml
  # GET /magnet_feeds/:id.xml
  def feed
    @podcast = Podcast.find(params[:id])

    render :xml => @podcast.as(params[:type])
  end

  # GET /:podcast_slug
  def status
    @queued_feed = QueuedFeed.find_by_url(params[:podcast])
    @podcast     = @queued_feed.podcast if @queued_feed

    # See http://wiki.limewire.org/index.php?title=LimeCast_Add#Messages
    # Unexpected errors
    if @queued_feed.nil?
      render :partial => 'status_error'
    # Successes
    elsif @podcast && @queued_feed.parsed? && queued_feed_created_just_now_by_user?(@queued_feed)
      render :partial => 'status_added'
    elsif @podcast && @queued_feed.parsed?
      render :partial => 'status_conflict'
    # Progress
    elsif @queued_feed.pending?
      render :partial => 'status_loading'
    # Expected errors
    elsif !@queued_feed.failed?
      render :partial => 'status_failed'
    # Really unexpected errors
    else
      render :partial => 'status_error'
    end
  end
  
  # POST /podcasts?url=...
  def create
    @queued_feed = QueuedFeed.find_or_initialize_by_url(params[:podcast][:url])

    if @queued_feed.new_record?
      @queued_feed.save
      remember_unclaimed_record(@queued_feed)
    else
      @queued_feed.save
    end

    render :nothing => true
  end

  
  # DELETE /:podcast_slug
  def destroy
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    authorize_write @podcast

    @podcast.destroy

    redirect_to(podcasts_url)
  end

  # TODO we should refactor/DRY up this method
  def update
    @podcast = Podcast.find_by_slug(params[:podcast_slug])

    authorize_write @podcast

    # The "_delete" attr is taken from Nested Association Attributes, but AR doesn't support
    # it on a regular model, so we're going to use the same convention when deleting the Podcast.
    if params[:podcast] && params[:podcast][:_delete] == '1'
      @podcast.destroy
      redirect_to(podcasts_url) and return false
    end

    # Set user-specific Podcast attributes if necessary
    params[:podcast][:tag_string] = [params[:podcast][:tag_string], current_user] if params[:podcast][:tag_string]

    @podcast.attributes = params[:podcast].slice(:has_p2p_acceleration, :has_previews, :protected,
                                                 :tag_string, :custom_title, :format, :itunes_link)


    respond_to do |format|
      if @podcast.save
        format.html do
          flash[:has_messages] = true unless @podcast.messages.empty?
          redirect_to @podcast
        end
        format.js { render :text => render_to_string(:partial => 'podcasts/form') }
      else
        format.html {
          show; render :action => 'show'
        }
        format.js { head(:failure) }
      end
    end
  end

  def favorite
    @podcast = Podcast.find_by_slug(params[:podcast_slug])

    unless has_unclaimed_record?(Favorite, lambda {|f| f.podcast == @podcast })
      @favorite = Favorite.find_or_initialize_by_podcast_id_and_user_id(@podcast.id, current_user)
      @favorite.new_record? ? @favorite.save : @favorite.destroy
      remember_unclaimed_record(@favorite)
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :json => {:logged_in => logged_in?} }
    end
  end


  protected

    def queued_feed_in_session?(queued_feed)
      has_unclaimed_record?(QueuedFeed, lambda {|i| i.id == queued_feed.id })
    end

    def queued_feed_created_by_user?(queued_feed)
      queued_feed_in_session?(queued_feed) or queued_feed.user == current_user
    end

    def queued_feed_created_just_now_by_user?(queued_feed)
      queued_feed_created_by_user?(queued_feed) && queued_feed.created_at > 2.minutes.ago
    end
end

class PodcastsController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => :status

  def index
    @podcasts = Podcast.parsed.find(:all, :order => "title ASC")
  end

  def show
    @podcast = Podcast.find_by_clean_url(params[:podcast])
		raise ActiveRecord::RecordNotFound if @podcast.nil? || params[:podcast].nil?

    @episodes = @podcast.episodes.find(:all, :order => "published_at DESC", :limit => 3)

    @comments = with(@podcast.episodes.newest.first) {|ep| ep.nil? ? [] : ep.comments }
    @comment  = Comment.new(:episode => @podcast.episodes.newest.first)
  end

  def search
    if params[:q]
      redirect_to :controller => 'podcasts', :action => 'search', :query => params[:q]
    else
      @query = params[:query]
      @podcasts = Podcast.search(@query)
    end
  end

  def new
  end

  def cover
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
  end

  def create
    @feed = Feed.create(:url => params[:feed][:url], :finder => current_user)

    if current_user.nil?
      session.data[:feeds] ||= []
      session.data[:feeds] << @feed.id
    end

    render :nothing => true
  end

  def update
    raise ActiveRecord::RecordNotFound if params[:podcast].nil?
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
    authorize_write @podcast

    @podcast.attributes = params[:podcast_attr].keep_keys([:custom_title])

    if @podcast.save
      flash[:notice] = 'Podcast was successfully updated.'
      redirect_to(@podcast)
    else
      render :action => "edit"
    end
  end

  def destroy
    @podcast = Podcast.find(params[:id])
    authorize_write @podcast

    @podcast.destroy

    redirect_to(podcasts_url)
  end

  protected
  
    def feed_in_session?(feed)
      (session.data[:feeds] and session.data[:feeds].include?(feed.id))
    end
    
    def feed_created_by_user?(feed)
      feed_in_session?(feed) or feed.writable_by?(current_user)
    end

    def feed_created_just_now_by_user?(feed)
      feed_created_by_user?(feed) && feed.just_created?
    end
end

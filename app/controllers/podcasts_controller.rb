class PodcastsController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy]

  def index
    @podcasts = Podcast.sorted.
      paginate(:page => (params[:page] || 1), :per_page => params[:limit] || 5)
  end

  def recs
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug])
  end

  def show
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug])
    raise ActiveRecord::RecordNotFound if @podcast.nil? || params[:podcast_slug].nil?

    @feeds    = @podcast.feeds.all
    @podcast.feeds.build if logged_in? # build a new one so we can include a new Feed in our form
    @episodes = @podcast.episodes.
      paginate(:order => "published_at DESC", :page => (params[:page] || 1), :per_page => params[:limit] || 5)

    @reviews = @podcast.reviews
    @review  = Review.new(:episode => @podcast.episodes.newest.first)

    render
  end

  def info
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug])
    render :layout => "info"
  end

  def search
    if params[:q]
      redirect_to :controller => 'podcasts', :action => 'search', :query => params[:q]
    else
      @query = params[:query]
      @podcasts = Podcast.search(@query)
    end
  end

  def cover
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug]) or raise ActiveRecord::RecordNotFound
    @feeds   = @podcast.feeds.all
  end

  def new
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
    raise ActiveRecord::RecordNotFound if params[:podcast_slug].nil?
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug]) or raise ActiveRecord::RecordNotFound
    authorize_write @podcast

    @podcast.attributes = params[:podcast].keep_keys([:has_p2p_acceleration, :has_previews, 
                                                      :feeds_attributes, :custom_title, :primary_feed_id])

    respond_to do |format|
      if @podcast.save
        format.html do
          flash[:notice] = 'Podcast was successfully updated.'
          redirect_to(@podcast)
        end
        format.js { render :text => render_to_string(:partial => 'podcasts/form') }
      else
        format.html { render :action => "edit" }
        format.js { head(:failure) }
      end
    end
  end

  def favorite
    raise ActiveRecord::RecordNotFound if params[:podcast_slug].nil?
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug]) or raise ActiveRecord::RecordNotFound

    if current_user
      @favorite = Favorite.find_or_initialize_by_podcast_id_and_user_id(@podcast.id, current_user.id)
      @favorite.new_record? ? @favorite.save : @favorite.destroy
    else
      session[:favorite] = @podcast.id
    end

    respond_to do |format|
      if @favorite
        format.html { redirect_to :back }
        format.js { render :json => {:logged_in => true} }
      else
        format.js { render :json => {:logged_in => false, :message => "Sign up or sign in to save your favorite:"} }
      end
    end

  end

  def destroy
    @podcast = Podcast.find(params[:id])
    authorize_write @podcast

    @podcast.destroy

    redirect_to(podcasts_url)
  end
end

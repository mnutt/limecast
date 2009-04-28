class PodcastsController < ApplicationController
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
      :include => :podcast, 
      :group => :podcast_id
    ).map(&:podcast)
    
    # @podcasts = Podcast.sorted_by_newest_episode.paginate(
    #   :page => (params[:page] || 1),
    #   :per_page => params[:limit] || 10
    # )

    respond_to do |format|
      format.xml { render :index }
    end
  end

  def show
    @podcast ||= Podcast.find_by_slug(params[:podcast_slug])

    @newest_episode = @podcast.newest_episode

    @episodes = @podcast.episodes.all(:include => :sources)
    @related  = @podcast.related_podcasts
    @reviews  = @podcast.reviews.all
    @review   = Review.new(:episode => @newest_episode)
  end

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
    params[:podcast][:feeds_attributes].each do |key,value|
      unless params[:podcast][:feeds_attributes][key].has_key?('id')
        params[:podcast][:feeds_attributes][key][:finder_id] = current_user.id
      end
    end if params[:podcast][:feeds_attributes].respond_to?(:each)

    @podcast.attributes = params[:podcast].keep_keys([:has_p2p_acceleration, :has_previews, :protected,
                                                      :tag_string, :feeds_attributes, :title, :primary_feed_id])


    @podcast.feeds
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
end

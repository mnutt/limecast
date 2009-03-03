class PodcastsController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy]

  def index
    @podcasts = Podcast.parsed.sorted
  end

  def popular
    @podcasts = Podcast.parsed.sorted.
      paginate(:page => (params[:page] || 1), :per_page => params[:limit] || 10)
  end

  def recs
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug])
  end

  def show
    @podcast ||= Podcast.find_by_clean_url(params[:podcast_slug])
    raise ActiveRecord::RecordNotFound if @podcast.nil? || params[:podcast_slug].nil?

    @feeds = @podcast.feeds.all
    @most_recent_episode = @podcast.episodes.newest.first
    @episodes = @podcast.episodes


    @related = Recommendation.for_podcast(@podcast).by_weight.first(5).map(&:related_podcast)

    @reviews = @podcast.reviews
    @review  = Review.new(:episode => @podcast.episodes.newest.first)
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
  end

  # TODO we should refactor/DRY up this method
  def update
    raise ActiveRecord::RecordNotFound if params[:podcast_slug].nil?
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug]) or raise ActiveRecord::RecordNotFound
    authorize_write @podcast

    # The "_delete" attr is taken from Nested Association Attributes, but AR doesn't support
    # it on a regular model, so we're going to use the same convention when deleting the Podcast.
    if params[:podcast] && params[:podcast][:_delete] == '1'
      @podcast.destroy
      redirect_to(podcasts_url) and return false
    end

    # Set user-specific Podcast attributes if necessary
    params[:podcast][:tag_string] = [params[:podcast][:tag_string], current_user] if params[:podcast][:tag_string]
    params[:podcast][:feeds_attributes].each {|key,value|
      params[:podcast][:feeds_attributes][key][:finder_id] = current_user.id if key.to_s =~ /^new\_/
    } if params[:podcast][:feeds_attributes].respond_to?(:each)

    @podcast.attributes = params[:podcast].keep_keys([:has_p2p_acceleration, :has_previews, :tag_string,
                                                      :feeds_attributes, :title, :primary_feed_id])

    respond_to do |format|
      if @podcast.save
        PodcastMailer.deliver_updated_podcast_from_site(@podcast)

        format.html do
          flash[:notice] = "#{@podcast.messages.join(' ')}"
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
        format.html {
          flash[:notice] = "Signup or sign in first to save your favorite."
          redirect_to new_session_path
        }
        format.js { render :json => {:logged_in => false, :message => "Sign up or sign in to save your favorite:"} }
      end
    end

  end

  def destroy
    raise ActiveRecord::RecordNotFound if params[:podcast_slug].nil?
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug]) or raise ActiveRecord::RecordNotFound
    authorize_write @podcast

    @podcast.destroy

    redirect_to(podcasts_url)
  end
end

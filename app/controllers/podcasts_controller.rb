class PodcastsController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy, :tag]

  def index
    @podcasts = Podcast.parsed.sorted
  end

  def popular
    @podcasts = Podcast.parsed.sorted.paginate(
      :page => (params[:page] || 1),
      :per_page => params[:limit] || 10
    )
  end

  def show
    @podcast ||= Podcast.find_by_slug(params[:podcast_slug])

    @most_recent_episode = @podcast.most_recent_episode

    @episodes = @podcast.episodes
    @feeds    = @podcast.feeds
    @related  = @podcast.related_podcasts
    @reviews  = @podcast.reviews
    @review   = Review.new(:episode => @most_recent_episode)
  end

  def info
    @podcast = Podcast.find_by_slug(params[:podcast_slug])

    render :layout => "info"
  end

  def destroy
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    authorize_write @podcast

    @podcast.destroy

    redirect_to(podcasts_url)
  end

  # TODO move this to UserTaggingsController
  def tag
    @podcast = Podcast.find_by_slug(params[:podcast_slug])

    if tags = params[:podcast].delete(:tag_string)
      tags.gsub!(/,/, '')
      @podcast.update_attribute :tag_string, [tags, current_user]
    end

    redirect_to(@podcast)
  rescue ActiveRecord::RecordInvalid
    flash[:notice] = "You are only allowed to add 8 tags for this podcast." if @podcast.taggings
    redirect_to(@podcast)
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

    @podcast.attributes = params[:podcast].keep_keys([:has_p2p_acceleration, :has_previews, :tag_string,
                                                      :feeds_attributes, :title, :primary_feed_id])


    @podcast.feeds
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
    @podcast = Podcast.find_by_slug(params[:podcast_slug])

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
end

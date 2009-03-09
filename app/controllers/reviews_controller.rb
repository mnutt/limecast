class ReviewsController < ApplicationController
  before_filter :login_required, :only => [:new, :update]

  def index
    redirect_to :action => :show, :controller => :podcasts
  end

  def info
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @review = @podcast.reviews.find(params[:id])
    render :layout => 'info'
  end

  def search
    @q = params[:q]
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @feeds   = @podcast.feeds

    @reviews = Review.search(@q, :with => {:podcast_id => @podcast.id}).compact.uniq
    render :action => 'index'
  end

  def show
    @review = Review.find(params[:id])

    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @feeds   = @podcast.feeds
  end

  def new
    @review = Review.new
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @feeds   = @podcast.feeds
  end

  def edit
    @review = Review.find(params[:id])
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @feeds   = @podcast.feeds

    redirect_to(:back) rescue redirect_to('/') unless @review.editable?
  end

  def create
    review_params = params[:review].keep_keys([:title, :body, :positive, :episode_id])
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @review = Review.new(review_params)

    if current_user
      @review.reviewer = current_user
      @review.save!
    else
      session[:review] = review_params
    end

    render :layout => false
  end

  def update
    @review = Review.find(params[:id])
    @podcast = Podcast.find_by_slug(params[:podcast_slug])

    @review.update_attributes(params[:review])

    redirect_to :back
  end

  def rate
    @review = Review.find(params[:id])

    insightful = !(params[:rating] =~ /not/)
    if current_user
      ReviewRating.create(:review => @review, :user => current_user, :insightful => insightful)
      respond_to {|format| format.js { render :json => {:logged_in => true } } }
    else
      session[:rating] = {:review_id => @review.id, :insightful => insightful}
      respond_to {|format| format.js { render :json => {:logged_in => false, :message => "Sign up or sign in to rate this review."} } }
    end
  end

  def destroy
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @review = @podcast.reviews.find(params[:id])
    @review.destroy

    session.data[:reviews].delete(params[:id]) if session.data[:reviews]

    respond_to do |format|
      format.js   { render :nothing => true }
      format.html { redirect_to episode_url(@review.episode.podcast, @review.episode) }
    end
  end

  protected

  def filter(reviews, f)
    case f
    when "positive": reviews.that_are_positive
    when "negative": reviews.that_are_negative
    else reviews
    end
  end

end

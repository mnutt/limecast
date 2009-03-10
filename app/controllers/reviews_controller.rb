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
      render :json => {:logged_in => true }
    else
      session[:rating] = {:review_id => @review.id, :insightful => insightful}
      render :json => {:logged_in => false, :message => "Sign up or sign in to rate this review."}
    end
  end

  def destroy
    Review.destroy(params[:id])
    session.data[:reviews].delete(params[:id]) if session.data[:reviews]

    render :nothing => true
  end
end

class ReviewsController < ApplicationController
  before_filter :login_required, :only => [:new, :update]

  def index
    redirect_to :action => :show, :controller => :podcasts
  end

  def create
    @podcast      = Podcast.find_by_slug(params[:podcast_slug])
    raise ActiveRecord::RecordNotFound if @podcast.nil?

    unless has_unclaimed_record?(Review, lambda {|r| r.podcast == @podcast })
      @review = @podcast.reviews.create(params[:review].slice(:title, :body, :positive))
      remember_unclaimed_record(@review) if @review
    end

    if logged_in?
      save_response(@review, (@review && !@review.new_record?))
    else
      render :json => {:success => true, :login_required => true}
    end
  end

  def update
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @review = @podcast.reviews.find(params[:id])

    save_response(@review, @review.update_attributes(params[:review]))
  end

  def rate
    @review = Review.find(params[:id])
    insightful = !(params[:rating] =~ /not/)

    unless has_unclaimed_record?(ReviewRating, lambda { |rr| rr.review == @review})
      @rating = ReviewRating.create(:review => @review, :insightful => insightful)
      remember_unclaimed_record(@rating)
    end

    render :json => {:logged_in => logged_in?}
  end

  def destroy
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @review = @podcast.reviews.find(params[:id])
    session[:reviews].delete(params[:id]) if session[:reviews]

    save_response(nil, @review.destroy)
  end

  protected

  def save_response(review, success)
    if success
      render :json => {:success => true, :html => render_to_string(:partial => 'reviews/reviews', :object => @podcast.reviews.claimed, :locals => {:podcast => @podcast, :editable => true})}
    else
      render :json => {:success => false, :errors => "There was a problem:<br /> #{review.errors.full_messages.join('.<br /> ')}."}
    end
  end
end

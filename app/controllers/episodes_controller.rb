class EpisodesController < ApplicationController
  before_filter :login_required, :only => [:favorite]

  def index
    @podcast  = Podcast.find_by_clean_url(params[:podcast])
    @episodes = @podcast.episodes.find(:all, :include => [:podcast], :order => "published_at DESC")
    @feeds    = @podcast.feeds
  end

  def show
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    raise ActiveRecord::RecordNotFound if @podcast.nil? || params[:podcast].nil?

    @episode = @podcast.episodes.find_by_clean_url(params[:episode])
    raise ActiveRecord::RecordNotFound if @episode.nil? || params[:episode].nil?

    @feeds   = @podcast.feeds
    @review = Review.new(:episode => @episode)
  end

  def destroy
    unauthorized unless @episode.writable_by?(current_user)

    @episode = Episode.find(params[:id])
    @episode.destroy
  end
end

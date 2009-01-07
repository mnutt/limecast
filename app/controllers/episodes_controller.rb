class EpisodesController < ApplicationController
  before_filter :login_required, :only => [:favorite]

  def index
    @podcast  = Podcast.find_by_clean_url(params[:podcast])
    @episodes = @podcast.episodes.find(:all, :include => [:podcast], :order => "published_at DESC")
    @feeds    = @podcast.feeds
  end

  def search
    @q        = params[:q]
    @podcast  = Podcast.find_by_clean_url(params[:podcast])
    @episodes = @podcast.episodes.search(@q, :include => [:podcast]).compact.sort_by(&:published_at)
    @feeds    = @podcast.feeds
    render :action => 'index'
  end

  def show
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    raise ActiveRecord::RecordNotFound if @podcast.nil? || params[:podcast].nil?

    @episode = @podcast.episodes.find_by_clean_url(params[:episode])
    raise ActiveRecord::RecordNotFound if @episode.nil? || params[:episode].nil?

    @feeds   = @podcast.feeds
    @review = Review.new(:episode => @episode)

    @next_episode = @podcast.episodes.find(:first, :conditions => ["published_at > ?", @episode.published_at], :order => "published_at ASC")
    @previous_episode = @podcast.episodes.find(:first, :conditions => ["episodes.published_at < ?", @episode.published_at], :order => "published_at DESC")
  end

  def destroy
    @episode = Episode.find(params[:id])
    unauthorized unless @episode.writable_by?(current_user)

    @episode.destroy
  end
end

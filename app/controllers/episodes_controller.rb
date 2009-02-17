class EpisodesController < ApplicationController
  before_filter :login_required, :only => [:favorite]

  def index
    @podcast  = Podcast.find_by_clean_url(params[:podcast_slug])
    raise ActiveRecord::RecordNotFound if @podcast.nil?
    @episodes = @podcast.episodes.find(:all, :include => [:podcast], :order => "published_at DESC")
    @newest_episode = @episodes.first
    @oldest_episode = @episodes.last if @episodes.size > 1
    @feeds    = @podcast.feeds
  end

  def search
    @q        = params[:q]
    @podcast  = Podcast.find_by_clean_url(params[:podcast_slug])
    @episodes = @podcast.episodes.search(@q, :include => [:podcast]).compact.uniq.sort_by(&:published_at)
    @feeds    = @podcast.feeds
    render :action => 'index'
  end

  def show
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug])
    raise ActiveRecord::RecordNotFound if @podcast.nil? || params[:podcast_slug].nil?

    @episode = @podcast.episodes.find_by_clean_url(params[:episode])
    raise ActiveRecord::RecordNotFound if @episode.nil? || params[:episode].nil?

    @feeds   = @podcast.feeds
    @review = Review.new(:episode => @episode)

    @next_episode = @podcast.episodes.find(:first, :conditions => ["published_at > ?", @episode.published_at], :order => "published_at ASC")
    @previous_episode = @podcast.episodes.find(:first, :conditions => ["episodes.published_at < ?", @episode.published_at], :order => "published_at DESC")
  end

  def info
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug])
    @episode = @podcast.episodes.find_by_clean_url(params[:episode])

    render :layout => "info"
  end

  def destroy
    @episode = Episode.find(params[:id])
    unauthorized unless @episode.writable_by?(current_user)

    @episode.destroy
    render :layout => false, :status => 200, :text => ""
  end
end

class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all)
  end

  def show
    case params[:tag]
    when 'current'
      @badge = params[:tag]
      @podcasts = Podcast.all.map(&:newest_episode).compact.select { |e| e.published_at > 30.days.ago }.map(&:podcast)
    when 'stale'
      @badge = params[:tag]
      @podcasts = Podcast.all.map(&:newest_episode).compact.select { |e| e.published_at > 90.days.ago && e.published_at <= 30.days.ago }.map(&:podcast)
    when 'archive'
      @badge = params[:tag]
      @podcasts = Podcast.all.map(&:newest_episode).compact.select { |e| e.published_at <= 90.days.ago }.map(&:podcast)
    when /^(#{Podcast.all(:select => :language, :group => :language).map(&:language).join('|')})$/
      @badge = params[:tag]
      @podcasts = Podcast.find_all_by_language(@badge)
    else  
      @tag = Tag.find_by_name!(params[:tag])
      @podcasts = @tag.podcasts.all
    end
  end
end

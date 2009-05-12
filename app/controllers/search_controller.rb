class SearchController < ApplicationController
  before_filter :check_for_query

  def index
    params[:q] += " podcast:#{params[:podcast]}" if params[:podcast]
    @parsed_q = (@q = params[:q]).dup

    extract_podcast!
    extract_tags!
    extract_only!

    @parsed_q.strip!

    raise ActiveRecord::RecordNotFound if instance_variable_defined?(:@podcast) && @podcast.nil?

    # get all possible results from User, Tag, Episode, Review, and Podcast.
    @user     = User.find_by_login(@parsed_q) unless @only && @only != :user
    @tag      = Tag.find_by_name(@parsed_q) unless @only && @only != :tag
    @episodes = (@podcast ? @podcast.episodes : Episode).search(@parsed_q).compact.uniq unless @only && @only != :episodes
    @reviews  = (@podcast ? Review.for_podcast(@podcast) : Review).claimed.search(@parsed_q).compact.uniq  unless @only && @only != :reviews
    @podcasts = @podcast ? [@podcast] : Podcast.search(@parsed_q).compact.uniq unless @only && @only != :podcasts
  rescue => e
    throw e.inspect
  end

  def google
    render
  end

  protected
    def check_for_query
      redirect_to params.merge(:q => '') unless params[:q]
    end

    # match Podcast, ex: "games podcast:Diggnation"
    def extract_podcast!
      @parsed_q.gsub!(/(\b)*podcast\:(\S*)(\b)*/i, "")
      @podcast = Podcast.find_by_slug($2) unless $2.blank?
    end

    # match Tags, :ex: "games tags:hd,video" to match in tags hd and video
    def extract_tags!
      @parsed_q.gsub!(/(\b)*tags\:(\S*)(\b)*/i, "")
      @tags = $2.split(',') unless $2.blank?
    end

    # match Only, ex: "games only:review" to get only reviews
    def extract_only!
      @parsed_q.gsub!(/(\b)*only\:(\S*)(\b)*/i, "")
      @only = [:episodes, :reviews, :podcasts, :tag, :user].detect{|o| o == $2.to_sym} unless $2.blank?
    end

end

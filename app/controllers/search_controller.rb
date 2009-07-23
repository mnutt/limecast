class SearchController < ApplicationController
  before_filter :check_for_query

  def index
    params[:s] += " podcast:#{params[:podcast]}" if params[:podcast]
    @parsed_s = (@s = params[:s]).dup

    extract_podcast!
    logger.info "\n\nPODCAST IS #{@podcast.inspect}\n\n"
    extract_tags!
    extract_only!

    @parsed_s.strip!

    raise ActiveRecord::RecordNotFound if instance_variable_defined?(:@podcast) && @podcast.nil?

    # get all possible results from User, Tag, Episode, Review, and Podcast.
    @user     = User.find_by_login(@parsed_s) unless @only && @only != :user
    @tag      = Tag.find_by_name(@parsed_s) unless @only && @only != :tag
    logger.info "\n\n\nEOPISDEOS,"
    options = @podcast ? {:podcast_id => @podcast.id} : nil
    @episodes = Episode.search(@parsed_s, :with => options).compact.uniq unless @only && @only != :episodes
    logger.info "\n\n\n"
    @reviews  = (@podcast ? Review.for_podcast(@podcast) : Review).claimed.search(@parsed_s).compact.uniq  unless @only && @only != :reviews
    @podcasts = @podcast ? [@podcast] : Podcast.search(@parsed_s).compact.uniq unless @only && @only != :podcasts
  rescue => e
    throw e.inspect
  end

  def google
    render
  end

  protected
    def check_for_query
      redirect_to params.merge(:s => '') unless params[:s]
    end

    # match Podcast, ex: "games podcast:Diggnation"
    def extract_podcast!
      @parsed_s.gsub!(/(\b)*podcast\:(\S*)(\b)*/i, "")
      @podcast = Podcast.find_by_slug($2) unless $2.blank?
    end

    # match Tags, :ex: "games tags:hd,video" to match in tags hd and video
    def extract_tags!
      @parsed_s.gsub!(/(\b)*tags\:(\S*)(\b)*/i, "")
      @tags = $2.split(',') unless $2.blank?
    end

    # match Only, ex: "games only:review" to get only reviews
    def extract_only!
      @parsed_s.gsub!(/(\b)*only\:(\S*)(\b)*/i, "")
      @only = [:episodes, :reviews, :podcasts, :tag, :user].detect{|o| o == $2.to_sym} unless $2.blank?
    end

end

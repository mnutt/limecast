class SearchController < ApplicationController
  before_filter :check_for_query

  def show
    params[:query] += " podcast:#{params[:podcast]}" if params[:podcast]
    @parsed_query = (@query = params[:query]).dup

    extract_podcast!
    extract_tags!
    extract_only!

    @parsed_query.strip!

    raise ActiveRecord::RecordNotFound if instance_variable_defined?(:@podcast) && @podcast.nil?

    # get all possible results from User, Tag, Episode, Review, and Podcast.
#    @user     = User.find_by_login(@parsed_query) unless @only && @only != :user
#    @tag      = Tag.find_by_name(@parsed_query) unless @only && @only != :tag
    options = {:page => 1, :per_page => 10, :with => {}}
    options[:with].merge(:podcast_id => @podcast.id) if @podcast
    
    @episodes = Episode.search(@parsed_query, options).compact.uniq unless @only && @only != :episodes
    @reviews  = Review.claimed.search(@parsed_query, options).compact.uniq unless @only && @only != :reviews
    @podcasts = @podcast ? [@podcast] : Podcast.search(@parsed_query, options).compact.uniq unless @only && @only != :podcasts
  end

  def google
    render
  end

  protected
    def check_for_query
      redirect_to params.merge(:query => '') unless params[:query]
    end

    # match Podcast, ex: "games podcast:Diggnation"
    def extract_podcast!
      @parsed_query.gsub!(/(\b)*podcast\:(\S*)(\b)*/i, "")
      @podcast = Podcast.find_by_slug($2) unless $2.blank?
    end

    # match Tags, :ex: "games tags:hd,video" to match in tags hd and video
    def extract_tags!
      @parsed_query.gsub!(/(\b)*tags\:(\S*)(\b)*/i, "")
      @tags = $2.split(',') unless $2.blank?
    end

    # match Only, ex: "games only:review" to get only reviews
    def extract_only!
      @parsed_query.gsub!(/(\b)*only\:(\S*)(\b)*/i, "")
      @only = [:episodes, :reviews, :podcasts, :tag, :user].detect{|o| o == $2.to_sym} unless $2.blank?
    end

end

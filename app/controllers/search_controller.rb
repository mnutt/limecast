class SearchController < ApplicationController
  def index
    if params[:q]
      params[:q] += " podcast:#{params[:podcast]}" if params[:podcast]
      @parsed_q = (@q = params[:q].strip).dup

      extract_podcast!
      extract_tags!
      extract_only!

      @parsed_q.strip!

      raise ActiveRecord::RecordNotFound if instance_variable_defined?(:@podcast) && @podcast.nil?

      # get all possible results from User, Tag, Feed, Episode, Review, and Podcast.
      @user     = User.find_by_login(@parsed_q) unless @only && @only != :user
      @tag      = Tag.find_by_name(@parsed_q) unless @only && @only != :tag
      @feeds    = (@podcast ? @podcast.feeds : Feed).search(@parsed_q).compact.uniq unless @only && @only != :feeds
      @episodes = (@podcast ? @podcast.episodes : Episode).search(@parsed_q).compact.uniq unless @only && @only != :episodes
      @reviews  = (@podcast ? Review.for_podcast(@podcast) : Review).search(@parsed_q).compact.uniq  unless @only && @only != :reviews
      @podcasts = @podcast ? [@podcast] : Podcast.search(@parsed_q).compact.uniq unless @only && @only != :podcasts

      @podcast_groups = Hash.new { |h, k| h[k] = [] } # hash where the keys are the unique podcast ids,
                                                      # and the values are arrays of their search results
      def @podcast_groups.add(obj, podcast_id); self[podcast_id] << obj; end
      def @podcast_groups.count(klass); inject(0) { |count, p| count + p[1].select { |o| o.is_a?(klass) }.size }; end

      # Group all the podcast-related search results by podcast-id
      @feeds.each    { |f| @podcast_groups.add(f, f.podcast.id) } if @feeds
      @episodes.each { |e| @podcast_groups.add(e, e.podcast.id) } if @episodes
      @reviews.each  { |r| @podcast_groups.add(r, r.episode.podcast.id) } if @reviews
      @podcasts.each { |p| @podcast_groups.add(p, p.id) } if @podcasts

      # rewrites @podcasts to have all the podcasts we need
      # FIXME Added pagination, but now we're merely skipping all the results from the other podcasts we
      #       searched; might get out of hand later with more podcasts.
      @podcasts = (@tags ? Podcast.tagged_with(@tags) : Podcast).
        paginate(:conditions => {:id => @podcast_groups.keys}, :page => (params[:page]||1), :per_page => 3).compact #.sorted
    end
  end

  def google
    render
  end

  protected
    # match Podcast, ex: "games podcast:Diggnation"
    def extract_podcast!
      @parsed_q.gsub!(/(\b)*podcast\:(\S*)(\b)*/i, "")
      @podcast = Podcast.find_by_clean_url($2) unless $2.blank?
    end

    # match Tags, :ex: "games tags:hd,video" to match in tags hd and video
    def extract_tags!
      @parsed_q.gsub!(/(\b)*tags\:(\S*)(\b)*/i, "")
      @tags = $2.split(',') unless $2.blank?
    end

    # match Only, ex: "games only:feed" to get only feeds
    def extract_only!
      @parsed_q.gsub!(/(\b)*only\:(\S*)(\b)*/i, "")
      @only = [:feeds, :episodes, :reviews, :podcasts, :tag, :user].detect{|o| o == $2.to_sym} unless $2.blank?
    end
end

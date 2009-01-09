class SearchController < ApplicationController
  def index
    if params[:q]
      params[:q] += " podcast:#{params[:podcast]}" if params[:podcast]
      @parsed_q = (@q = params[:q].strip).dup

      # match Podcast, ex: "podcast:Diggnation"
      @parsed_q.gsub!(/(\b)*podcast\:(\S*)(\b)*/i, "")
      @podcast = Podcast.find_by_clean_url($2) unless $2.blank?

      # match Only, ex: "only:feed" to get only feeds
      @parsed_q.gsub!(/(\b)*only\:(\S*)(\b)*/i, "")
      only = [:feeds, :episodes, :reviews, :podcasts, :tag, :user].detect{|o| o == $2.to_sym} unless $2.blank?

      @parsed_q.strip!

      raise ActiveRecord::RecordNotFound if instance_variable_defined?(:@podcast) && @podcast.nil?

      # get all possible results from User, Tag, Feed, Episode, Review, and Podcast.
      @user     = User.find_by_login(@parsed_q) unless only && only != :user
      @tag      = Tag.find_by_name(@parsed_q) unless only && only != :tag
      @feeds    = (@podcast ? @podcast.feeds : Feed).search(@parsed_q).compact.uniq unless only && only != :feeds
      @episodes = (@podcast ? @podcast.episodes : Episode).search(@parsed_q).compact.uniq unless only && only != :episodes
      @reviews  = (@podcast ? Review.for_podcast(@podcast) : Review).search(@parsed_q).compact.uniq  unless only && only != :reviews
      @podcasts = @podcast ? [@podcast] : Podcast.search(@parsed_q).compact.uniq unless only && only != :podcasts

      @podcast_groups = Hash.new { |h, k| h[k] = [] } # hash where the keys are the unique podcast ids,
                                                      # and the values are arrays of their search results
      def @podcast_groups.add(obj, podcast_id); self[podcast_id] << obj; end
      def @podcast_groups.count(klass); self.inject(0) { |count, p| count + p[1].select { |o| o.is_a?(klass) }.size }; end

      # Group all the podcast-related search results by podcast-id
      @feeds.each    { |f| @podcast_groups.add(f, f.podcast.id) } if @feeds
      @episodes.each { |e| @podcast_groups.add(e, e.podcast.id) } if @episodes
      @reviews.each  { |r| @podcast_groups.add(r, r.episode.podcast.id) } if @reviews
      @podcasts.each { |p| @podcast_groups.add(p, p.id) } if @podcasts

      # rewrites @podcasts to have all the podcasts we need
      # FIXME Added pagination, but now we're skipping all the results from the other podcasts we 
      #       searched; might get out of hand later with more podcasts.
      @podcasts = Podcast.paginate(:conditions => {:id => @podcast_groups.keys}, :page => (params[:page]||1), :per_page => 3).compact #.sorted
    end
  end
end

class SearchController < ApplicationController
  def index
    q = (@q = params[:q]).dup
    
    # match Podcast, ex: "podcast:Diggnation"
    q.gsub!(/(\b)*podcast\:(\S*)(\b)*/i, "")
    @podcast = Podcast.find_by_clean_url($2) unless $2.blank?

    raise ActiveRecord::RecordNotFound if instance_variable_defined?(:@podcast) && @podcast.nil?

    # get all possible results from User, Tag, Feed, Episode, Review, and Podcast.
    @users    = User.search(q).compact
    @tags     = Tag.search(q).compact
    @feeds    = (@podcast ? @podcast.feeds : Feed).search(q).compact
    @episodes = (@podcast ? @podcast.episodes : Episode).search(q).compact
    @reviews  = (@podcast ? Review.for_podcast(@podcast) : Review).search(q).compact
    @podcasts = @podcast ? [@podcast] : Podcast.search(q).compact

    @podcast_groups = Hash.new { |h, k| h[k] = [] } # hash where the keys are the unique podcast ids,
                                                    # and the values are arrays of their search results
    def @podcast_groups.add(obj, podcast_id); self[podcast_id] << obj; end
    def @podcast_groups.count(klass); self.inject(0) { |count, p| count + p[1].map { |o| o.is_a?(klass) }.size }; end

    # Group all the podcast-related search results by podcast-id
    @feeds.each    { |f| @podcast_groups.add(f, f.podcast.id) } if @feeds
    @episodes.each { |e| @podcast_groups.add(e, e.podcast.id) } if @episodes
    @reviews.each  { |r| @podcast_groups.add(r, r.episode.podcast.id) } if @reviews
    @podcasts.each { |p| @podcast_groups.add(p, p.id) } if @podcasts

    # rewrites @podcasts to have all the podcasts we need
    @podcasts = Podcast.all(:conditions => {:id => @podcast_groups.keys}).compact #.sorted
  end
end

class SearchController < ApplicationController
  def index
    @q = params[:q]
    @users    = User.search(@q).compact
    @tags     = Tag.search(@q).compact
    @feeds    = Feed.search(@q).compact
    @episodes = Episode.search(@q).compact
    @reviews  = Review.search(@q)
    puts "The reviews are #{@reviews.size}"
    @podcasts = Podcast.search(@q).compact
    
    @podcast_groups = {}
    def @podcast_groups.add(obj, podcast_id); (self[podcast_id] ||= []) << obj; end
    def @podcast_groups.count(klass); self.inject(0) { |count, p| count + p[1].select { |o| o.is_a?(klass) }.size }; end

    @feeds.each    { |f| @podcast_groups.add(f, f.podcast_id) }
    @episodes.each { |e| @podcast_groups.add(e, e.podcast_id) }
    @reviews.each  { |r| @podcast_groups.add(r, r.episode.podcast_id) }
    @podcasts.each { |p| @podcast_groups.add(p, p.id) }

    # rewrite @podcasts to have all the podcasts we need
    @podcasts = Podcast.all(:conditions => {:id => @podcast_groups.keys}) #.sorted
  end
end

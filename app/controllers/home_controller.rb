class HomeController < ApplicationController
  def home
    @podcasts = Podcast.parsed.sorted

    @reviews = Review.claimed.all(:order => "created_at DESC")
    @review = @reviews.first

    @recent_reviews = Review.claimed.newest(2)
    @recent_episodes = Episode.newest(3)
    @popular_tags = Tag.all #(:order => "taggings_count DESC")

    @podcast1 = Podcast.find_by_clean_url("COOP") || Podcast.all[0]
    @podcast2 = Podcast.find_by_clean_url("Diggnation") || Podcast.all[1]
  end
end

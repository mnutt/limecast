module PodcastsHelper
  def rss_link(feed)
    "<link rel='alternate' type='application/rss+xml' title='#{feed.podcast.title}' href='#{feed.url}' />"
  end
end

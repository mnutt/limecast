module PodcastsHelper
  def rss_link(feed)
    %{<link rel="alternate" type="application/rss+xml" title="#{feed.formatted_bitrate} #{feed.apparent_format}" href="#{feed.url}" />}
  end
end

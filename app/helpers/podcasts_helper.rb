module PodcastsHelper
  def rss_link(feed)
    %{<link rel="alternate" type="application/rss+xml" title="(#{feed.apparent_format}, #{feed.formatted_bitrate})" href="#{feed.url}" />}
  end
end

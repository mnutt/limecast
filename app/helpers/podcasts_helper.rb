module PodcastsHelper
  def rss_link(feed)
    %{<link rel="alternate" type="application/rss+xml" title="#{feed.formatted_bitrate} #{feed.apparent_format}" href="#{feed.url}" />}
  end

  def cover_art(podcast, size = :small)
    if podcast.logo?
      podcast.logo.url(size)
    else
      "/imgs/no_cover.png"
    end
  end
end

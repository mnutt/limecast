# deprecated
module FeedsHelper
  def subscribe_title(feed)
    [feed.apparent_resolution, "bitrate: #{feed.formatted_bitrate}"].compact.join(" | ")
  end

  def link_to_itunes(feed)
    url = "http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewPodcast?id=#{feed.itunes_link}"
    link_to("iTunes", url, :class => "itunes", :title => "View #{feed.podcast.title} in iTunes")
  end
end


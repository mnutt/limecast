module FeedsHelper
  def feeds_label_from_format(format)
    {
      "mov" => "Quicktime",
      nil   => "Unknown"
    }[format] || format.upcase
  end

  def default_bitrate_label(bitrate)
    bitrate ||= 0
    if bitrate > 1.5 * 1024
      "HD"
    elsif bitrate > 1 * 1024
      "Large"
    elsif bitrate > 0.5 * 1024
      "Medium"
    else
      "Small"
    end
  end

  def subscribe_title(feed)
    [feed.apparent_resolution, "bitrate: #{feed.formatted_bitrate}"].compact.join(" | ")
  end

  def link_to_feed_size(feed, type, &url)
    link_to default_bitrate_label(feed.bitrate),
      url.call(feed),
      :id    => "feed_#{feed.id}_#{type}",
      :title => subscribe_title(feed),
      :class => (feed.primary? ? "primary" : nil)
  end
end


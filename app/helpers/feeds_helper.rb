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
end


module EpisodesHelper
  def scaled_resolution(res)
    scale_to_width = 460

    height = ((res[:width].to_f / scale_to_width) * res[:height]) rescue nil

    { :height => height, :width => scale_to_width }
  end
end

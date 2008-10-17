class Bitrate
  def initialize(size)
    @size = size
  end

  def to_s
    h = self.to_hash

    [:mbps, :kbps].map do |unit|
      "#{format(h[unit])} #{label(unit)}" if h.has_key?(unit)
    end.compact.join(" ")
  end

  def to_hash
    return {} if @size < 0

    case @size
    when 0
      {:kbps => 0}
    when (1..999)
      {:kbps => to_kbps(@size)}
    else
      {:mbps => to_mpbs(@size.to_f)}
    end
  end

  protected

  def format(size)
    size.is_a?(Integer) ? size.to_s : ("%.1f" % size)
  end

  def to_kbps(size)
    size / 1
  end

  def to_mpbs(size)
    size / 1000
  end

  def label(unit)
    {:mbps => "Mbps", :kbps => "Kbps"}[unit]
  end
end

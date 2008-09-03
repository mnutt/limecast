class FileSize
  def initialize(size)
    @size = size
  end

  def to_s(abbr = true)
    h = self.to_hash

    [:gigabytes, :megabytes, :kilobytes].map do |unit|
      "#{format(h[unit])} #{label(unit)}" if h.has_key?(unit)
    end.compact.join(" ")
  end

  def to_hash
    return {} if @size < 0

    case @size
    when 0
      {:kilobytes => 0}
    when (1.byte..(1.megabyte - 1.byte))
      {:kilobytes => to_kilobytes(@size)}
    when (1.megabyte..(32.megabytes - 1.byte))
      {:megabytes => to_megabytes(@size.to_f)}
    when (32.megabytes..(1.gigabyte - 1.byte))
      {:megabytes => to_megabytes(@size)}
    else
      {:gigabytes => to_gigabytes(@size.to_f)}
    end
  end

  protected

  def format(size)
    size.is_a?(Integer) ? size.to_s : ("%.1f" % size)
  end

  def to_kilobytes(size)
    size / 1.kilobyte
  end

  def to_megabytes(size)
    size / 1.megabyte
  end

  def to_gigabytes(size)
    size / 1.gigabyte
  end

  def label(unit)
    {:gigabytes => "GB", :megabytes => "MB", :kilobytes => "KB"}[unit]
  end
end

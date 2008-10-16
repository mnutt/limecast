class Numeric
  def nearest_multiple_of(n)
    lower = (self / n).to_i * n
    upper = lower + n

    dist_from_lower = self - lower
    dist_from_upper = upper - self

    if dist_from_upper < dist_from_lower
      upper
    else
      lower
    end
  end
end


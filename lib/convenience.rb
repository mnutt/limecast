module Convenience
  # Do while with counter
  def iterate(start = 0, step = 1, &b)
    i = start
    keep_going = false
    begin
      keep_going = b.call(i)
      i += step
    end while keep_going
  end

  def with(*vars, &b)
    b.call(*vars)
  end
end


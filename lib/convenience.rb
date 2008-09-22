module Convenience
  def with(*vars, &b)
    b.call(*vars)
  end
end


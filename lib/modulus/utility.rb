module Utility
  
  MILLISECOND = 0.001

  def sq(x)
    x*x
  end

  def dist_sq x1, y1, x2, y2
    len_sq x1-x2,y1-y2
  end

  def len_sq x, y
    sq(x) + sq(y)
  end

  def dist x1, y1, x2, y2
    Math::sqrt(dist_sq(x1, y1, x2, y2))
  end

  def len x, y
    Math::sqrt(len_sq(x,y))
  end

  def dot x1, y1, x2, y2
    x1*x2 + y1*y2
  end

  def lerp a, b, u
    a*u + b*(1.0-u)
  end
  
end
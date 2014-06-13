require 'matrix'

class Vector
  def x
    self[0]
  end
  def y
    self[1]
  end
  def len_sq
    x*x + y*y
  end
  def len
    Math::sqrt(len_sq)
  end
  def dot other
    x*other.x + y*other.y
  end
  def self.from_angle angle
    Vector[Math::cos(angle),Math::sin(angle)]
  end
  def zero?
    x.zero? && y.zero?
  end
end

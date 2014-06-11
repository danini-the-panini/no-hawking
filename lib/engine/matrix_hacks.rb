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
  def normalized
    Vector[x/len,y/len]
  end
end

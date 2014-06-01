module Garbage
  class Transform
    def initialize x = 0.0, y = 0.0, rotation = 0.0
      @x = x
      @y = y
      @rotation = rotation
    end

    def x
      @x
    end

    def x= new_x
      @x = new_x
    end

    def y
      @y
    end

    def y= new_y
      @y = new_y
    end

    def rotation
      @rotation
    end

    def rotation= new_rotation
      @rotation = new_rotation
    end

    def translate x, y
      @x += x
      @y += y
    end

    def translate_to x, y
      @x = x
      @y = y
    end

    def rotate theta
      @rotation += theta
    end

    def rotate_to theta
      @rotation = theta
    end
  end
end

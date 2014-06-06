module Garbage
  class Transform
    def initialize position = Vector[0,0], rotation = 0.0
      @position = position
      @rotation = rotation
    end

    def position
      @position
    end

    def rotation
      @rotation
    end

    def rotation= new_rotation
      @rotation = new_rotation
    end

    def translate x, y
      @position += Vector[x,y]
    end

    def position= new_position
      @position = new_position
    end

    def rotate theta
      @rotation += theta
    end

    def rotation= theta
      @rotation = theta
    end
  end
end

require 'gosu'

module Garbage
  class Renderer
    def initialize sprite, anchor = Vector[0.5,0.5], color = Gosu::Color::WHITE
      @sprite = sprite
      @anchor = anchor
      @color = color
    end

    def sprite
      @sprite
    end

    def draw transform
      @sprite.draw_rot transform.position.x, transform.position.y, 0,
        transform.rotation*180.0/Math::PI, @anchor.x, @anchor.y, 1.0, 1.0, @color
    end
  end
end


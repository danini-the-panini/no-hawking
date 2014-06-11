require 'gosu'

module Garbage
  class Renderer
    def initialize sprite, anchor = Vector[0.5,0.5]
      @sprite = sprite
      @anchor = anchor
    end

    def sprite
      @sprite
    end

    def draw transform
      @sprite.draw_rot transform.position.x, transform.position.y, 0,
        transform.rotation, @anchor.x, @anchor.y
    end
  end
end


require 'gosu'

module Garbage
  class Renderer
    def initialize sprite
      @sprite = sprite
    end

    def draw transform
      @sprite.draw_rot transform.position.x, transform.position.y, 0,
        transform.rotation, 0.5, 0.5
    end
  end
end


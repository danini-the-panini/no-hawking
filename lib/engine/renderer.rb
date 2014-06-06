require 'gosu'

module Garbage
  class Renderer
    def initialize sprite
      @sprite = sprite
    end

    def draw transform
      @sprite.draw transform.position.x, transform.position.y, 0
    end
  end
end


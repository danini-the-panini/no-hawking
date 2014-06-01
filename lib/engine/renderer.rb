require 'gosu'

module Garbage
  class Renderer
    def initialize sprite
      @sprite = sprite
    end

    def draw transform
      @sprite.draw transform.x, transform.y, 0
    end
  end
end


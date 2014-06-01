require_relative 'transformable'
require_relative 'renderer'

module Garbage
  class Renderable < Transformable
    def initialize sprite
      super()
      @renderer = Renderer.new sprite
    end

    def renderer
      @renderer
    end

    def draw
      @renderer.draw @transform
    end
  end
end

require 'gosu'

require_relative 'transformable'
require_relative 'renderer'


module Garbage
  class Renderable < Transformable
    def initialize sprite, anchor = Vector[0.5,0.5], color = Gosu::Color::WHITE
      super()
      @renderer = Renderer.new sprite, anchor, color
    end

    def renderer
      @renderer
    end

    def draw
      @renderer.draw @transform
    end
  end
end

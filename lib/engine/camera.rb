require 'matrix'
require_relative 'matrix_hacks'
require_relative 'component'

module Garbage

  class Camera < Component
    def initialize
    end

    # TODO: take scale and rotation into account?
    def screen2world_x x
      x-@engine.window.width/2+@entity.transform.position.x
    end

    def screen2world_y y
      y-@engine.window.height/2+@entity.transform.position.y
    end

    def screen2word v
      Vector[screen2world_x(v.x), screen2world_y(v.y)]
    end

    def world2screen_x x
      x+@engine.window.width/2-@entity.transform.position.x
    end

    def world2screen_y y
      y+@engine.window.height/2-@entity.transform.position.y
    end

    def world2screen v
      Vector[world2screen_x(v.x), world2screen_y(v.y)]
    end

  end

end

require 'gosu'
require_relative 'engine/component'

class Control < Garbage::Component
  def initialize thrust
    @a - thrust
  end

  def update
    if @engine.button_down? Gosu::KbA
      @entity.physics.force.x -= @a
    end
    if @engine.button_down? Gosu::KbD
      @entity.physics.force.x += @a
    end
    if @engine.button_down? Gosu::KbW
      @entity.physics.force.y -= @a
    end
    if @engine.button_down? Gosu::KbS
      @entity.physics.force.y += @a
    end
  end
end

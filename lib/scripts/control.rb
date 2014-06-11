require 'gosu'
require_relative '../engine/component'

class Control < Garbage::Component
  def initialize thrust
    @thrust_x = Vector[thrust,0.0]
    @thrust_y = Vector[0.0,thrust]
  end

  def update
    @entity.physics.driving_force = VEC2_ZERO
    if @engine.button_down? Gosu::KbLeft
      @entity.physics.driving_force -= @thrust_x
    end
    if @engine.button_down? Gosu::KbRight
      @entity.physics.driving_force += @thrust_x
    end
    if @engine.button_down? Gosu::KbUp
      @entity.physics.driving_force -= @thrust_y
    end
    if @engine.button_down? Gosu::KbDown
      @entity.physics.driving_force += @thrust_y
    end
  end
end

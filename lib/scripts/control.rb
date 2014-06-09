require 'gosu'
require_relative '../engine/component'

class Control < Garbage::Component
  def initialize thrust
    @thrust_x = Vector[thrust,0.0]
    @thrust_y = Vector[0.0,thrust]
  end

  def update
    @entity.physics.driving_force = VEC2_ZERO
    if @engine.button_down? Gosu::KbA
      @entity.physics.driving_force -= @thrust_x
    end
    if @engine.button_down? Gosu::KbD
      @entity.physics.driving_force += @thrust_x
    end
    if @engine.button_down? Gosu::KbW
      @entity.physics.driving_force -= @thrust_y
    end
    if @engine.button_down? Gosu::KbS
      @entity.physics.driving_force += @thrust_y
    end
  end
end

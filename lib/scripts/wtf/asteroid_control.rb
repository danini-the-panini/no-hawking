require 'gosu'
require_relative '../../engine/component'
require_relative '../../engine/matrix_hacks'

class AsteroidControl < Garbage::Component
  def initialize thrust, torque
    @thrust = thrust
    @torque = torque
  end

  def update
    @entity.physics.angular_acc = 0.0
    @entity.physics.driving_force = VEC2_ZERO
    if @engine.button_down? Gosu::KbLeft
      @entity.physics.angular_acc -= @torque
    end
    if @engine.button_down? Gosu::KbRight
      @entity.physics.angular_acc += @torque
    end
    if @engine.button_down? Gosu::KbUp
      @entity.physics.driving_force += calculate_thrust
    end
    if @engine.button_down? Gosu::KbDown
      @entity.physics.driving_force -= calculate_thrust
    end
  end

  private

    def calculate_thrust
      Vector::from_angle(@entity.transform.rotation)*@thrust
    end
end

require_relative '../engine/component'

class Physics < Garbage::Component
  attr_accessor :mass, :friction, :angular_friction, :velocity, :acceleration,
    :driving_force, :angular_v, :angular_acc

  def initialize mass = 1.0, friction = 0.0, angular_friction = friction
    @mass = mass
    @friction = friction
    @angular_friction = angular_friction
    @velocity = Garbage::VEC2_ZERO
    @acceleration = Garbage::VEC2_ZERO
    @driving_force = Garbage::VEC2_ZERO
    @angular_v = 0.0
    @angular_acc = 0.0
  end

  def update
    friction_force = -@friction * @velocity
    forces = friction_force + @driving_force
    @acceleration = forces/@mass
    @velocity += @acceleration * @engine.delta
    @entity.transform.position += @velocity * @engine.delta

    angular_damp = -@angular_friction * @angular_v
    @angular_v += (@angular_acc + angular_damp) * @engine.delta
    @entity.transform.rotation += @angular_v * @engine.delta
  end
end

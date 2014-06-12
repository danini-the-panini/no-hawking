require_relative '../engine/component'

class Physics < Garbage::Component
  def initialize mass = 1.0, friction = 0.0, angular_friction = friction
    @mass = mass
    @friction = friction
    @angular_friction = angular_friction
    @velocity = VEC2_ZERO
    @acceleration = VEC2_ZERO
    @driving_force = VEC2_ZERO
    @angular_v = 0.0
    @angular_acc = 0.0
  end

  def velocity
    @velocity
  end

  def velocity= v
    @velocity = v
  end

  def acceleration
    @acceleration
  end

  def driving_force
    @driving_force
  end

  def driving_force= f
    @driving_force = f
  end

  def angular_acc= v
    @angular_acc = v
  end

  def angular_acc
    @angular_acc
  end

  def angular_v
    @angular_v
  end

  def mass
    @mass
  end

  def friction
    @friction
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

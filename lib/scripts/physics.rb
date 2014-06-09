require_relative '../engine/component'

class Physics < Garbage::Component
  def initialize mass = 1.0, friction = 0.0
    @mass = mass
    @friction = friction
    @velocity = VEC2_ZERO
    @acceleration = VEC2_ZERO
    @driving_force = VEC2_ZERO
    @friction_force = VEC2_ZERO
  end

  def velocity
    @velocity
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

  def mass
    @mass
  end

  def friction
    @friction
  end

  def update
    @friction_force = -@friction * @velocity
    forces = @friction_force + @driving_force
    @acceleration = forces/@mass
    @velocity += @acceleration * @engine.delta
    @entity.transform.position += @velocity * @engine.delta
  end
end

require_relative '../modulus/engine'

class Particle < Entity
  include Drawable
  include Life
  include Position
  include Velocity

  def initialize x, y, vx, vy, life, sprite, engine
    super(engine)

    init_position x, y
    init_velocity vx, vy
    init_life life
    init_drawable sprite
  end

  def update dt, t
    do_life dt, t
    do_velocity dt, t
  end

  def draw window
    do_draw window
  end

end
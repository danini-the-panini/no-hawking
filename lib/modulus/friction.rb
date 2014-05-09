module Friction

  def init_friction coeff = 0.0
    @friction = coeff
  end

  def friction
    @friction
  end

  def do_friction dt, t
    @fx += -@friction*@vx
    @fy += -@friction*@vy
  end

end
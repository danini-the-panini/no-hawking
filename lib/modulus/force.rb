module Force

  def init_force x = 0.0, y = 0.0, m = 1.0
    @fx = x
    @fy = y
    @mass = 1.0
  end

  def fx
    @fx
  end

  def fy
    @fy
  end

  def mass
    @mass
  end
  
  def do_force dt, t
    @ax = @fx * @mass
    @ay = @fy * @mass
    @fx = @fy = 0
  end
  
end
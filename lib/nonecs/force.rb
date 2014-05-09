module Force

  def force
    @force
  end
  
  def do_force dt, t
    @acceleration[:x] = @force[:x] * @mass
    @acceleration[:y] = @force[:y] * @mass
  end
  
end
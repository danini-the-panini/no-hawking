module Life

  def init_life life
    @lifetime = @life = life
  end

  def lifetime
    @lifetime
  end

  def life
    @life
  end

  def do_life dt, t
    @life -= dt
    if @life > 0
      @colour ||= (((@life/@lifetime)*0xFF).to_i << 24) | (@colour ? (@colour & 0x00FFFFFF) : 0x00FFFFFF)
    else
      @engine.remove_me
    end
  end

end
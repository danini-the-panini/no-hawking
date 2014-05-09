module Emitter

  def init_emitter period, speed, life, sprite, &block
    @last_emit = 0
    @emit_period = period
    @particle_speed = speed
    @particle_life = life
    @particle_sprite = sprite
    @proc_emit = block
  end

  def do_emitter dt, t
    if t-@last_emit > @emit_period
      @proc_emit.call()
    end
  end

end
module Emitter

  def init_emitter period, speed, life, sprite
    @last_emit = 0
    @emit_period = period
    @particle_speed = speed
    @particle_life = life
    @particle_sprite = sprite
  end

  def do_emitter dt, t
    if t-@last_emit > @emit_period
      theta = Gosu::random(0,2*Math::PI)

      @engine.add_entity(Particle.new(
        @x, @y,
        @particle_speed*Math::cos(theta),
        @particle_speed*Math::sin(theta),
        @particle_life,
        @particle_sprite
      ))
    end
  end

end
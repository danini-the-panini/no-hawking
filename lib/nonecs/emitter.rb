module Emitter

  def do_emitter dt, t
    if t-@last_emit > @emit_period
      theta = Gosu::random(0,2*Math::PI)

      @engine.add_entity(Particle.new(
        @position[:x], @position[:y],
        @particle_speed*Math::cos(theta),
        @particle_speed*Math::sin(theta),
        @particle_life,
        @particle_sprite
      ))
    end
  end

end
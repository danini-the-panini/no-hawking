require_relative '../engine/component'
require_relative 'physics'
require_relative 'life'

class Emitter < Garbage::Component
  attr_accessor :velocity, :lifetime, :period, :sprite

  def initialize velocity, lifetime, period, sprite
    @velocity = velocity
    @sprite = sprite
    @lifetime = lifetime
    @period = period
    @last_emit = 0
  end

  def update
    if @engine.time-@last_emit > @period
      @engine.add_entity :particle, make_particle
    end
  end

  def make_particle
    theta = Gosu::random(0,360)

    particle = Garbage::Renderable.new(@sprite)
    particle.transform.position = @entity.transform.position

    physics = Physics.new
    physics.velocity = Vector[
      @velocity * Math::cos(theta),
      @velocity * Math::sin(theta)
    ]
    particle.add_component :physics, physics

    particle.add_component :life, Life.new(@lifetime)
    particle
  end
end

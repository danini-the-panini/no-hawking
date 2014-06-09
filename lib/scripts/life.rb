require_relative '../engine/component'

class Life < Garbage::Component
  def initialize life
    @life = life.to_f
    @lifetime = life.to_f
  end

  def life
    @life
  end

  def lifetime
    @lifetime
  end

  def life_percent
    @life / @lifetime
  end

  def update
    @life -= @engine.delta
    @entity.destroy! if @life <= 0
  end
end

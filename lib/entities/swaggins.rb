require_relative '../modulus/entity'
require_relative '../custom_modules/player'

class Swaggins < Entity
  include Player
  include Drawable

  def initialize sprite, engine
    super(engine)

    init_player
    init_drawable sprite
  end

  def update dt, t
    do_player dt, t
  end

  def draw window
    do_draw window
  end
end
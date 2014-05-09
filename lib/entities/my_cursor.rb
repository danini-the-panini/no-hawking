require_relative '../modulus/cursor'

class MyCursor < Entity
  include Cursor
  include Position
  include Drawable

  def initialize sprite, engine
    super(engine)

    init_cursor
    init_position
    init_drawable sprite
  end

  def update dt, t
    do_cursor dt, t
  end

  def draw window
    do_draw_screen window
  end

end
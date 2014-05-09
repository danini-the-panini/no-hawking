module Cursor

  def init_cursor
  end

  def do_cursor dt, t
    @x, @y = @engine.mouse_in_screen_coords
  end

end
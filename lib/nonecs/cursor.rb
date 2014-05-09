module Cursor

  def do_cursor dt, t
    @position[:x], @position[:y] = @engine.mouse_in_screen_coords
  end

end
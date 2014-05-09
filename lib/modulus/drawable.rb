require 'gosu'

module Drawable

  def init_drawable sprite, x = 0.5, y = 0.5, sx = 1.0, sy = 1.0, colour = 0xFFFFFFFF, draw_mode = :default
    @sprite = sprite
    @anchor_x = x
    @anchor_y = y
    @sx = sx
    @sy = sy
    @colour = colour
    @draw_mode = draw_mode

    @rotation ||= 0.0
  end

  def do_draw window
    window::translate(*(@engine.world2screen(0,0))) do
      do_draw_screen window, 0
    end
  end

  def do_draw_screen window, z=1
    @sprite.draw_rot @x, @y, z, @rotation, @anchor_x, @anchor_y, @sx, @sy, @colour, @draw_mode
  end

end
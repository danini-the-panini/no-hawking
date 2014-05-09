require 'gosu'

module Drawable

  def set_sprite sprite
    @sprite = sprite
    @sprite[:anchor] ||= {:x => 0.5, :y => 0.5}
    @scale ||= {:x => 1.0, :y => 1.0}
    @rotation ||= 0.0
  end

  def draw_sprite window
    window::translate(*world2screen(0,0)) do
      draw_entity_nocam window, 0
    end
  end

  def draw_sprite_nocam window, z=1
    x = @position[:x]
    y = @position[:y]
    img = @sprite[:image]
    dx = @sprite[:anchor][:x]
    dy = @sprite[:anchor][:y]
    colour = e[:colour] || 0xFFFFFFFF
    mode = e[:draw_mode] || :default
    img.draw_rot x, y, z, @rotation, dx, dy, @scale[:x], @scale[:y], colour, mode
  end

end
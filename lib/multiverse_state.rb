require_relative 'ingame_state'

class MultiverseState < IngameState
  def initialize window
    super

    @engine
    .system(:draw, :white_hole_draw, [:position, :sprite, :white_hole]) do |e|
      @window::translate(*world2screen(0,0)) do
        x = e[:position][:x]
        y = e[:position][:y]
        img = e[:sprite][:image]
        dx = e[:sprite][:anchor][:x]*img.width*e[:white_hole][:size]
        dy = e[:sprite][:anchor][:y]*img.height*e[:white_hole][:size]
        img.draw x-dx, y-dy, 0, e[:white_hole][:size], e[:white_hole][:size]
      end
    end
    .system(:update, :pulse_hole, [:white_hole, :pulsate]) do |dt, t, e|
      if t % e[:pulsate][:period] < @window.update_interval
        e[:white_hole][:size] = e[:pulsate][:base_size]*Gosu::random(e[:pulsate][:min],e[:pulsate][:max])
      end
      e
    end
    .add_entity(gen_player.merge({
      :player => {:a => 30},
      :sprite => ECS::make_sprite(Gosu::Image.new @window, "spr_player.png")
    }))
    .add_entity(gen_white_hole(-100,-100))
    .add_entity(gen_white_hole(200,-100))
    .add_entity(gen_white_hole(50,200))
  end

  def gen_white_hole x, y
    {
      :white_hole => {:size => 0},
      :pulsate => {:min => Gosu::random(0.7,0.9), :max => Gosu::random(1.1,1.3), :period => 0.2,
        :base_size => Gosu::random(0.6,1.4)},
      :position => {:x => x, :y => y},
      :sprite => ECS::make_sprite(Gosu::Image.new @window, "white_hole.png")
    }
  end
end
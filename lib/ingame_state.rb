require_relative 'engine_state'

class IngameState < EngineState
  def initialize window
    super

    @engine.input_system(:down, :pcontrol, [:player,:acceleration]) do |id, e|
      case id
      when Gosu::KbA
        e[:acceleration][:x] -= e[:player][:a]
      when Gosu::KbD
        e[:acceleration][:x] += e[:player][:a]
      when Gosu::KbW
        e[:acceleration][:y] -= e[:player][:a]
      when Gosu::KbS
        e[:acceleration][:y] += e[:player][:a]
      end
    end
    .input_system(:up, :pcontrol, [:player,:velocity]) do |id, e|
      case id
      when Gosu::KbA
        e[:acceleration][:x] += e[:player][:a]
      when Gosu::KbD
        e[:acceleration][:x] -= e[:player][:a]
      when Gosu::KbW
        e[:acceleration][:y] += e[:player][:a]
      when Gosu::KbS
        e[:acceleration][:y] -= e[:player][:a]
      end
    end
    .system(:draw, :sprite_draw_rotated, [:position, :sprite, :rotation]) do |e|
      @window::translate(*world2screen(0,0)) do
        x = e[:position][:x]
        y = e[:position][:y]
        img = e[:sprite][:image]
        dx = e[:sprite][:anchor][:x]
        dy = e[:sprite][:anchor][:y]
        img.draw_rot x, y, 0, e[:rotation][:theta], dx, dy
      end
    end
    .system(:draw, :sprite_draw, [:position, :sprite, :norotate]) do |e|
      @window::translate(*world2screen(0,0)) do
        x = e[:position][:x]
        y = e[:position][:y]
        img = e[:sprite][:image]
        dx = e[:sprite][:anchor][:x]*img.width
        dy = e[:sprite][:anchor][:y]*img.height
        img.draw x-dx, y-dy, 0
      end
    end
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
    .system(:update, :acceleration, [:velocity, :acceleration]) do |dt, t, e|
      e[:velocity][:x] += e[:acceleration][:x]*dt
      e[:velocity][:y] += e[:acceleration][:y]*dt
      e
    end
    .system(:update, :movement, [:position, :velocity]) do |dt, t, e|
      e[:position][:x] += e[:velocity][:x]*dt
      e[:position][:y] += e[:velocity][:y]*dt
      e
    end
    .system(:update, :follow_mouse, [:position, :rotation, :follow_mouse]) do |dt, t, e|
      mx, my = screen2world(@window.mouse_x, @window.mouse_y)
      rad = Math::atan2(my-e[:position][:y], mx-e[:position][:x])
      e[:rotation][:theta] = (rad*180.0)/Math::PI
      e
    end
    .system(:update, :cursor, [:position, :cursor]) do |dt, t, e|
      mx, my = screen2world(@window.mouse_x, @window.mouse_y)
      e[:position][:x] = mx
      e[:position][:y] = my
      e
    end
    .system(:update, :pulse_hole, [:white_hole, :pulsate]) do |dt, t, e|
      if t % e[:pulsate][:period] < @window.update_interval
        e[:white_hole][:size] = e[:pulsate][:base_size]*Gosu::random(e[:pulsate][:min],e[:pulsate][:max])
      end
      e
    end
    .add_entity({
      :player => {:a => 30},
      :follow_mouse => {},
      :sprite => ECS::make_sprite(Gosu::Image.new @window, "spr_player.png"),
      :position => {:x => 0, :y => 0},
      :rotation => {:theta => 0},
      :velocity => {:x => 0, :y => 0},
      :acceleration => {:x => 0, :y => 0},
      :force => {:x => 0, :y => 0}
    })
    .add_entity({
      :cursor => true,
      :sprite => ECS::make_sprite(Gosu::Image.new @window, "cursor.png"),
      :position => {:x => 0, :y => 0},
      :norotate => true
    })
    .add_entity(gen_white_hole(-100,-100))
    .add_entity(gen_white_hole(200,-100))
    .add_entity(gen_white_hole(50,200))
  end

  def screen2world x, y
    [x-@window.width/2, y-@window.height/2]
  end

  def world2screen x, y
    [x+@window.width/2, y+@window.height/2]
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
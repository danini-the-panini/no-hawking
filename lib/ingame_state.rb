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
    .system(:draw, :sprite_draw, [:position, :sprite, :rotation]) do |e|
      @window::translate(*world2screen(0,0)) do
        x = e[:position][:x]
        y = e[:position][:y]
        img = e[:sprite][:image]
        dx = e[:sprite][:anchor][:x]
        dy = e[:sprite][:anchor][:y]
        img.draw_rot x, y, 0, e[:rotation][:theta], dx, dy
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
  end

  def screen2world x, y
    [@window.width/2-x, @window.height/2-y]
  end

  def world2screen x, y
    [x+@window.width/2, y+@window.height/2]
  end
end
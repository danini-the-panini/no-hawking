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
    .system(:draw, :sprite_draw, [:position, :sprite]) do |e|
      x = e[:position][:x]
      y = e[:position][:y]
      img = e[:sprite][:image]
      dx = e[:sprite][:anchor][:x]*img.width
      dy = e[:sprite][:anchor][:y]*img.height
      img.draw x-dx, y-dy, 0
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
    .add_entity({
      :player => {:a => 30},
      :sprite => ECS::make_sprite(Gosu::Image.new @window, "spr_player.png"),
      :position => {:x => 0, :y => 0},
      :velocity => {:x => 0, :y => 0},
      :acceleration => {:x => 0, :y => 0},
      :force => {:x => 0, :y => 0}
    })
  end
end
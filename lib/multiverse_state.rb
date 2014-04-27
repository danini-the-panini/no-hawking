require_relative 'ingame_state'
require_relative 'universe_state'

class MultiverseState < IngameState
  def initialize window
    super

    @white_hole_img = Gosu::Image.new @window, "white_hole.png"

    @engine
    .system(:draw, :white_hole_draw, [:position, :sprite, :white_hole]) do |e|
      draw_entity e
    end
    .system(:update, :pulse_hole, [:white_hole, :emitter, :pulsate]) do |dt, t, e|
      if t % e[:pulsate][:period] < @window.update_interval
        pulse_factor = Gosu::random(e[:pulsate][:min],e[:pulsate][:max])
        scale = e[:pulsate][:base_size]*pulse_factor
        e[:emitter][:velocity] = e[:pulsate][:base_velocity]*scale
        e[:scale][:x] = e[:scale][:y] = scale
      end
      e
    end
    .input_system(:down, :enter_universe, [:white_hole, :position]) do |id, e|
      if id == Gosu::MsLeft
        @engine.each_entity([:player, :position]) do |pl|
          if dist_sq(pl[:position][:x],pl[:position][:y],e[:position][:x],e[:position][:y]) <= sq(e[:white_hole][:activate_radius])
            e[:universe] = gen_universe if e[:universe].empty?
            enter_universe e[:universe]
          end
        end
      end
    end
    .add_entity(gen_player.merge({
      :player => {:a => 30},
      :sprite => ECS::make_sprite(Gosu::Image.new @window, "spr_player.png")
    }))
    .add_entity(gen_white_hole(-100,-100)) ## TODO: procedurally generate these
    .add_entity(gen_white_hole(200,-100))
    .add_entity(gen_white_hole(50,200))
  end

  def gen_white_hole x, y
    {
      :white_hole => {:activate_radius => @white_hole_img.width/2},
      :pulsate => {:min => Gosu::random(0.7,0.9), :max => Gosu::random(1.1,1.3), :period => 0.2,
        :base_size => Gosu::random(0.6,1.4), :base_velocity => 20},
      :position => {:x => x, :y => y},
      :scale => {:x => 1, :y => 1},
      :sprite => ECS::make_sprite(@white_hole_img),
      :emitter => gen_emitter,
      :colour => Gosu::Color.rgba(Gosu::random(127,255).to_i, Gosu::random(127,255).to_i,
        Gosu::random(127,255).to_i, 255),
      :universe => {} # No universe by default. Will generate one if neccessary
    }
  end

  def gen_universe
    ## TODO: generate more interesting universes
    [
      gen_player.merge({ ## TODO: Change to probe-player
        :player => {:a => 30},
        :sprite => ECS::make_sprite(Gosu::Image.new @window, "spr_player.png")
      }),
      {
        :position => {:x => Gosu::random(-200,200), :y => Gosu::random(-200,200)},
        :sprite => ECS::make_sprite(Gosu::Image.from_text @window, "Random:#{Gosu::random(0,1000)}", Gosu::default_font_name, 50),
        :rotation => {:theta => Gosu::random(0,360)}
      }
    ]
  end

  def enter_universe universe
    universe_state = UniverseState.new @window, universe
    @window.add_state(:universe_state, universe_state)
           .change_state(:universe_state)
  end
end
require_relative 'ingame_state'
require_relative 'universe_state'

class MultiverseState < IngameState
  def initialize window
    super

    @white_hole_img = Gosu::Image.new @window, "white_hole.png"

    @starting_probes = 5
    @hawking_requirement = (@starting_probes/2).to_f+1.0

    @last_visited_universe = nil
    @last_entered_hole = nil

    @engine
    .input_system(:down, :enter_universe, [:white_hole, :position]) do |id, e|
      if id == Gosu::MsLeft
        @engine.each_entity([:player, :position]) do |pl|
          if dist_sq(pl[:position][:x],pl[:position][:y],e[:position][:x],e[:position][:y]) <= sq(e[:white_hole][:activate_radius])
            @last_entered_hole = e
            e[:universe] = {} if e[:universe].nil?
            enter_universe e[:universe]
            break
          end
        end
      end
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
    .system(:update, :hawking_bar, [:hawking_bar]) do |dt, t, e|
      @engine.each_entity([:player, :hawking]) do |pl|
        e[:scale][:x] = pl[:hawking]/@hawking_requirement
      end
      e
    end
    .system(:update, :game_loop, [:player, :hawking, :probes]) do |dt, t, e|
      if e[:hawking] - @hawking_requirement > -0.05
        e[:hawking] = @hawking_requirement
        puts "Winning!"
      elsif e[:probes] <= 0
        puts "Losing!"
      end
      e
    end
    .system(:draw, :white_hole_draw, [:position, :sprite, :white_hole]) do |e|
      draw_entity e
    end
    .add_entity(gen_player.merge({
      :sprite => make_sprite(Gosu::Image.new @window, "spr_player.png"),
      :hawking => 0.0,
      :probes => @starting_probes
    }))
    .add_entity({
      :hud => true,
      :hawking_bar => true,
      :position => {:x => 10, :y => @window.height-10},
      :sprite => make_sprite((Gosu::Image.new @window, "hawking_bar.png"),{:x => 0.0, :y => 1.0}),
      :scale => {:x => 0.0, :y => 1.0}
    })
    .add_entity({
      :hud => true,
      :position => {:x => 10, :y => @window.height-10},
      :sprite => make_sprite((Gosu::Image.new @window, "hawking_bar_border.png"),{:x => 0.0, :y => 1.0})
    })
    .add_entity({
      :visited => {},
      :chunk_size => 1000
    })
  end

  def gen_white_hole x, y
    {
      :white_hole => {:activate_radius => @white_hole_img.width/2},
      :pulsate => {:min => Gosu::random(0.7,0.9), :max => Gosu::random(1.1,1.3), :period => 0.2,
        :base_size => Gosu::random(0.6,1.4), :base_velocity => 20},
      :position => {:x => x, :y => y},
      :scale => {:x => 1, :y => 1},
      :sprite => make_sprite(@white_hole_img),
      :emitter => gen_emitter,
      :colour => Gosu::Color.rgba(Gosu::random(127,255).to_i, Gosu::random(127,255).to_i,
        Gosu::random(127,255).to_i, 255)
    }
  end

  def proc_gen xi, yi, xj, yj
    3.times do
      @engine
      .add_entity(gen_white_hole(Gosu::random(xi,xj),
        Gosu::random(yi,yj)))
    end
  end

  def enter_universe universe
    @last_visited_universe = UniverseState.new @window, universe
    @window.add_state(:universe_state, @last_visited_universe)
           .change_state(:universe_state)
  end

  def enter_state
    super

    unless @last_visited_universe.nil?
      @engine.each_entity([:player, :hawking]) do |pl|
        pl[:hawking] += @last_visited_universe.get_hawking
      end
      @last_entered_hole[:universe] = @last_visited_universe.get_entities
      @last_visited_universe = nil
    end
  end

end
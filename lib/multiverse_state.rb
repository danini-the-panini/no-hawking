require_relative 'ingame_state'
require_relative 'universe_state'

class MultiverseState < IngameState
  def initialize window
    super

    @white_hole_img = Gosu::Image.new @window, "effects/spr_glow.png"
    @spr_player = Gosu::Image.new @window, "actors/spr_player.png"

    @starting_probes = 5
    @hawking_requirement = (@starting_probes/2).to_f+1.0

    @last_visited_universe = nil
    @last_entered_hole = nil

    @engine
    .input_system(:down, :enter_universe, [:white_hole, :position]) do |id, e|
      if id == Gosu::MsLeft
        pl = @engine.get_entity @player_id
        if dist_sq(pl[:position][:x],pl[:position][:y],e[:position][:x],e[:position][:y]) <= sq(e[:white_hole][:activate_radius])
          @last_entered_hole = e
          e[:universe] = {} if e[:universe].nil?
          pl[:probes] -= 1
          enter_universe e[:universe]
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
      pl = @engine.get_entity @player_id
      e[:scale][:x] = (300.0*pl[:hawking]/@hawking_requirement)/16.0
      e
    end
    .system(:update, :probe_icons, [:probe_icon]) do |dt, t, e|
      pl = @engine.get_entity @player_id
      if e[:probe_icon] >= pl[:probes]
        e[:colour] = 0x33FFFFFF
      end
      e
    end
    .system(:update, :game_loop, [:player, :hawking, :probes]) do |dt, t, e|
      if e[:hawking] - @hawking_requirement > -0.05
        e[:hawking] = @hawking_requirement
        @engine.add_entity({
          :hud => true,
          :sprite => make_sprite(Gosu::Image.from_text(@window, "You Win", Gosu::default_font_name, 50)),
          :position => {x: @window.width/2, :y => @window.height/2}
        })
      elsif e[:probes] <= 0
        @engine.add_entity({
          :hud => true,
          :sprite => make_sprite(Gosu::Image.from_text(@window, "You Lose", Gosu::default_font_name, 50)),
          :position => {x: @window.width/2, :y => @window.height/2}
        })
      end
      e
    end
    .add_entity(gen_player.merge({
      :sprite => make_sprite(@spr_player),
      :hawking => 0.0,
      :probes => @starting_probes
    }))
    .add_entity({
      :hud => true,
      :position => {:x => @window.width/2, :y => 10},
      :sprite => make_sprite((@spr_bar_bg),{:x => 0.5, :y => 0.0}),
      :scale => {:x => 300.0/16.0, :y => 1.0}
    })
    .add_entity({
      :hud => true,
      :hawking_bar => true,
      :position => {:x => @window.width/2, :y => 10},
      :sprite => make_sprite((@spr_bar_hawking),{:x => 0.5, :y => 0.0}),
      :scale => {:x => 0.0, :y => 1.0}
    })

    @starting_probes.times do |i|
      @engine.add_entity({
        :hud => true,
        :probe_icon => i,
        :position => {:x => @window.width/2-@spr_probe.width*(@starting_probes/2.0)+i*@spr_probe.width, :y => @window.height-10},
        :sprite => make_sprite((@spr_probe),{:x => 0.0, :y => 1.0}),
        :rotation => {:theta => -90}
      })
    end

    @engine.each_entity([:player]) { |e| @player_id = e[:id] }
  end

  def gen_white_hole x, y
    {
      :white_hole => {:activate_radius => @white_hole_img.width/2},
      :pulsate => {:min => Gosu::random(0.7,0.9), :max => Gosu::random(1.1,1.3), :period => 0.2,
        :base_size => Gosu::random(0.6,1.4), :base_velocity => 20},
      :position => {:x => x, :y => y},
      :norotate => true,
      :scale => {:x => 1, :y => 1},
      :sprite => make_sprite(@white_hole_img),
      :emitter => gen_emitter,
      :colour => Gosu::Color.rgba(Gosu::random(127,255).to_i, Gosu::random(127,255).to_i,
        Gosu::random(127,255).to_i, 255)
    }
  end

  def proc_gen xi, yi, chunk_size
    x1 = xi*chunk_size
    y1 = yi*chunk_size
    x2 = x1+chunk_size
    y2 = y1+chunk_size
    3.times do
      @engine
      .add_entity(gen_white_hole(Gosu::random(x1,x2),
        Gosu::random(y1,y2)),[xi,yi])
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
      # @last_entered_hole[:universe] = @last_visited_universe.get_chunks
      @last_entered_hole[:delete] = true
      @last_visited_universe = nil
    end
  end

end
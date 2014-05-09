require_relative 'ingame_state'
require_relative 'universe_state'
require_relative 'entities/swaggins'

class MultiverseState < IngameState
  def initialize window
    super

    @music = Gosu::Song.new @window, "mus/Calm Ambient.ogg"

    @white_hole_img = Gosu::Image.new @window, "effects/spr_glow.png"
    @spr_player = Gosu::Image.new @window, "actors/spr_player.png"

    @probes = 5
    @hawking_requirement = (@probes/2).to_f+1.0
    @hawking = 0

    @last_visited_universe = nil
    @last_entered_hole = nil

    @player = Swaggins.new(@spr_player, @engine)
    @engine.add_entity @player
    @white_holes = []

    @engine.on_proc_gen do |xi, yi, chunk_size|
      x1 = xi*chunk_size
      y1 = yi*chunk_size
      x2 = x1+chunk_size
      y2 = y1+chunk_size

      chunk_name = [xi,yi]

      # @engine
      # .add_entity_to_chunk({
      #   :position => {:x => x1+chunk_size/2, :y => y1+chunk_size/2},
      #   :sprite => make_sprite(Gosu::Image.new @window, "dbg_chunk.png"),
      # }, chunk_name, :drawable)

      3.times do
        @engine
        .add_entity_to_chunk(gen_white_hole(Gosu::random(x1,x2),
          Gosu::random(y1,y2)),chunk_name,:white_hole, :drawable, :emitter)
      end
    end

    # @engine
    # .add_system(:update, :hawking_bar, :hawking_bar) do |e, dt, t|
    #   @engine.each_entity(:player) do |pl|
    #     e[:scale][:x] = (300.0*pl[:hawking]/@hawking_requirement)/16.0
    #   end
    # end
    # .add_system(:update, :probe_icons, :probe_icon) do |e, dt, t|
    #   @engine.each_entity(:player) do |pl|
    #     if e[:probe_icon] >= pl[:probes]
    #       e[:colour] = 0x33FFFFFF
    #     end
    #   end
    # end
    # .add_system(:update, :game_loop, :player) do |e, dt, t|
    #   if e[:hawking] - @hawking_requirement > -0.05
    #     e[:hawking] = @hawking_requirement
    #     @engine.add_entity({
    #       :sprite => make_sprite(Gosu::Image.from_text(@window, "You are saved", Gosu::default_font_name, 50)),
    #       :position => {x: @window.width/2, :y => @window.height/2}
    #     }, :hud)
    #     @end_game ||= t
    #   elsif e[:probes] <= 0
    #     @engine.add_entity({
    #       :sprite => make_sprite(Gosu::Image.from_text(@window, "You are lost", Gosu::default_font_name, 50)),
    #       :position => {x: @window.width/2, :y => @window.height/2}
    #     }, :hud)
    #     @end_game ||= t
    #   end
    #   if @end_game && t-@end_game > 5.0
    #     @window.change_state(:start)
    #   end
    # end
    # .add_entity(gen_player.merge({
    #   :sprite => make_sprite(@spr_player),
    #   :hawking => 0.0,
    #   :probes => @starting_probes
    # }), :player, :force, :acceleration, :velocity, :friction, :cam_follow, :follow_mouse, :drawable)
    # .add_entity({
    #   :position => {:x => @window.width/2, :y => 10},
    #   :sprite => make_sprite((@spr_bar_bg),{:x => 0.5, :y => 0.0}),
    #   :scale => {:x => 300.0/16.0, :y => 1.0}
    # }, :hud)
    # .add_entity({
    #   :hawking_bar => true,
    #   :position => {:x => @window.width/2, :y => 10},
    #   :sprite => make_sprite((@spr_bar_hawking),{:x => 0.5, :y => 0.0}),
    #   :scale => {:x => 0.0, :y => 1.0}
    # }, :hud, :hawking_bar)

    # @starting_probes.times do |i|
    #   @engine.add_entity({
    #     :probe_icon => i,
    #     :position => {:x => @window.width/2-@spr_probe.width*(@starting_probes/2.0)+i*@spr_probe.width, :y => @window.height-10},
    #     :sprite => make_sprite((@spr_probe),{:x => 0.0, :y => 1.0}),
    #     :rotation => {:theta => -90}
    #   }, :hud, :probe_icon)
    # end

  end

  def button_down id
    super

    if id == Gosu::MsLeft && !@end_game
      @white_holes.each do |e|
        if dist_sq(@player.x,@player.y, e.x, e.y) <= sq(e.activate_radius)
          @last_entered_hole = e
          e.universe ||= {}
          @probes -= 1
          enter_universe e.universe
        end
      end
    end
  end

  def enter_universe universe
    @last_visited_universe = UniverseState.new @window, universe
    @window.add_state(:universe_state, @last_visited_universe)
           .change_state(:universe_state)
  end

  def enter_state
    super

    @music.play true

    unless @last_visited_universe.nil?
      @hawking += @last_visited_universe.get_hawking
      # @last_entered_hole[:universe] = @last_visited_universe.get_state
      @engine.remove_entity @last_entered_hole, :all
      @last_visited_universe = nil
    end
  end

  def leave_state
    @music.stop
  end

end
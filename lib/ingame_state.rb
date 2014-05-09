require_relative 'engine_state'

class IngameState < EngineState
  def initialize window
    super

    @cam_follow_factor = 1.0
    @sleep_radius = 1000

    @particle = Gosu::Image.new @window, "effects/spr_particle.png"

    @spr_bar_bg = Gosu::Image.new @window, "ui/spr_bar_bg.png"
    @spr_bar_hawking = Gosu::Image.new @window, "ui/spr_bar_hawking.png"

    @spr_probe = Gosu::Image.new @window, "actors/spr_probe.png"
  end

  def enter_state
    # @engine.each_entity do |e|
    #   e.force = 0
    # end
    @engine.unpause
  end

  def leave_state
    @engine.pause
  end

  def update
    super

    @window.caption = "fps: #{Gosu::fps.to_s}" #, c: #{@engine.total_chunks}, ac: #{@engine.active_chunks}, e: #{@engine.total_entities}, ae: #{@engine.active_entities}"
  end

end
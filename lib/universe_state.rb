require_relative 'ingame_state'

class UniverseState < IngameState
  def initialize window
    super

    @engine
    .add_entity(gen_player.merge({ ## TODO: Change to probe-player
      :player => {:a => 30},
      :sprite => ECS::make_sprite(Gosu::Image.new @window, "spr_player.png")
    }))
  end
end
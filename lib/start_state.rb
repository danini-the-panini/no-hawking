require_relative 'window_state.rb'

class StartState < WindowState

  def initialize window
    super

    @title = Gosu::Image.from_text @window, "No Hawking", Gosu::default_font_name, 50
    @title_x = @window.width/2-@title.width/2
    @title_y = 150
  end

  def update
  end

  def draw
    @title.draw @title_x, @title_y, 0
  end

end
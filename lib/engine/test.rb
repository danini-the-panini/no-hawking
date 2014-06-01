require_relative 'garbage.rb'

class TestComponent < Garbage::Component
  def button_down id
    puts "DBG: pressing #{id}"
    thing = Garbage::Renderable.new(Gosu::Image.from_text @engine.window, id.to_s, Gosu::default_font_name, 50)
    thing.transform.translate_to Gosu.random(100,300), Gosu.random(100,300)
    @engine.add_entity :thing, thing
  end
end

class Test < Gosu::Window
  def initialize width=800, height=600, fullscreen=false
    super width, height, fullscreen
    @engine = Garbage::Engine.new self


    player = Garbage::Renderable.new(Gosu::Image.from_text self, '<', Gosu::default_font_name, 10)
    player.transform.translate 50, 50
    player.add_component :test, TestComponent.new
    @engine.add_entity :player, player
  end

  %w(button_down button_up).each do |meth|
    define_method(meth) { |id|
      @engine.send(meth, id) }
  end

  %w(update draw).each do |meth|
    define_method(meth) { @engine.send(meth) }
  end
end

Test.new.show

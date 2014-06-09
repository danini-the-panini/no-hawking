require_relative 'garbage.rb'
require_relative '../scripts/control'
require_relative '../scripts/physics'
require_relative '../scripts/rigid_body'
require_relative '../scripts/follow'
require_relative '../scripts/face_mouse'
require_relative '../scripts/cursor'

class Test < Gosu::Window
  def initialize width=800, height=600, fullscreen=false
    super width, height, fullscreen
    @engine = Garbage::Engine.new self

    player = make_player

    cursor = Garbage::Renderable.new(Gosu::Image.from_text self, '+', Gosu::default_font_name, 20)
    cursor.add_component :cursor, Cursor.new
    @engine.add_entity :cursor, cursor

    @engine.main_camera.add_component :follow, Follow.new(player)
  end

  %w(button_down button_up).each do |meth|
    define_method(meth) { |id|
      @engine.send(meth, id) }
  end

  %w(update draw).each do |meth|
    define_method(meth) { @engine.send(meth) }
  end

  def make_player
    player = Garbage::Renderable.new(Gosu::Image.from_text self, '>', Gosu::default_font_name, 20)
    player.transform.translate 50, 50
    player.add_component :control, Control.new(200)
    player.add_component :face_mouse, FaceMouse.new()
    player.add_component :rigid_body, RigidBody.new(10.0)
    player.add_component :physics, Physics.new(1.0, 0.8)
    @engine.add_entity :player, player
    player
  end
end

Test.new.show

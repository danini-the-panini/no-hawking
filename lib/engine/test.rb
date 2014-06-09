require_relative 'garbage.rb'
require_relative '../scripts/control'
require_relative '../scripts/physics'
require_relative '../scripts/rigid_body'
require_relative '../scripts/follow'
require_relative '../scripts/face_mouse'
require_relative '../scripts/cursor'
require_relative '../scripts/emitter'

class Test < Gosu::Window
  def initialize width=800, height=600, fullscreen=false
    super width, height, fullscreen
    @engine = Garbage::Engine.new self

    player = make_player
    @engine.add_entity :player, player

    cursor = Garbage::Renderable.new(Gosu::Image.from_text self, '+', Gosu::default_font_name, 20)
    cursor.add_component :cursor, Cursor.new
    @engine.add_entity :cursor, cursor

    @engine.add_entity :emitter, make_emitter
  end

  %w(button_down button_up).each do |meth|
    define_method(meth) { |id|
      @engine.send(meth, id) }
  end

  %w(update draw).each do |meth|
    define_method(meth) { @engine.send(meth) }
  end

  def make_player
    player = Garbage::Renderable.new(
      Gosu::Image.from_text self, '>', Gosu::default_font_name, 20)
    player.add_component :control, Control.new(200)
    player.add_component :face_mouse, FaceMouse.new()
    player.add_component :rigid_body, RigidBody.new(10.0)
    player.add_component :physics, Physics.new(1.0, 0.8)
    @engine.main_camera.add_component :follow, Follow.new(player)
    player
  end

  def make_emitter
    emitter = Garbage::Renderable.new(
      Gosu::Image.from_text self, 'O', Gosu::default_font_name, 50)
    emitter.add_component :emitter, Emitter.new(20.0, 3, 0.5,
      Gosu::Image.from_text(self, '*', Gosu::default_font_name, 10))
    emitter.transform.translate(50, 50)
    emitter
  end
end

Test.new.show

require_relative 'garbage.rb'
require_relative '../scripts/control'
require_relative '../scripts/physics'
require_relative '../scripts/rigid_body'
require_relative '../scripts/follow'
require_relative '../scripts/face_mouse'
require_relative '../scripts/cursor'
require_relative '../scripts/emitter'
require_relative '../scripts/wtf/swear_word'

class Test < Gosu::Window

  LINE_HEIGHT = 20
  SPACE_WIDTH = 10

  def initialize width=800, height=600, fullscreen=false
    super width, height, fullscreen
    @engine = Garbage::Engine.new self

    player = make_player
    @engine.add_entity :player, player

    cursor = Garbage::Renderable.new(
      Gosu::Image.from_text self, '+', Gosu::default_font_name, 20)
    cursor.add_component :cursor, Cursor.new
    @engine.add_entity :cursor, cursor

    #@engine.add_entity :emitter, make_emitter

    make_paragraph 'There was an old man with a beard,
A funny old man with a beard
He had a big beard
A great big old beard
That amusing old man with a beard.', Vector[20.0,20.0]

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
    player.add_component :rigid_body, RigidBody.new(5.0)
    player.add_component :physics, Physics.new(1.0, 0.8)
    @engine.main_camera.add_component :follow, Follow.new(player)
    player
  end

  def make_emitter
    emitter = Garbage::Renderable.new(
      Gosu::Image.from_text self, 'O', Gosu::default_font_name, 50)
    emitter.add_component :emitter, Emitter.new(20.0, 3, 0.5,
      Gosu::Image.from_text(self, '*', Gosu::default_font_name, 20))
    emitter.transform.translate(50, 50)
    emitter
  end

  def make_paragraph text, position = Vector[0.0,0.0]
    x = position.x
    text.split("\n").each_with_index do |line, i|
      position = Vector[x,i*LINE_HEIGHT]
      p line
      line.split.each do |word|
        bad = Gosu::random(0.0,1.0) < 0.1
        word = 'fuck' if bad
        word_entity = make_word word.chomp, position, bad
        position += Vector[word_entity.renderer.sprite.width+SPACE_WIDTH,0.0]
      end
    end
  end

  def make_word word, position, bad
    word_sprite =
      Gosu::Image.from_text(self, word, Gosu::default_font_name, 30)
    word_entity = Garbage::Renderable.new(
      word_sprite, Vector[0.0,1.0],
      bad ? Gosu::Color::RED : Gosu::Color::WHITE)
    word_entity.add_component :physics, Physics.new
    word_entity.add_component :rigid_body, RigidBody.new(word_sprite.height/2)
    word_entity.add_component :swear_word, SwearWord.new(word) if bad
    word_entity.transform.position = position
    @engine.add_entity :word, word_entity
    word_entity
  end
end

Test.new.show

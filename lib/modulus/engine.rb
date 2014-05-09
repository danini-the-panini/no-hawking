require 'gosu'
require_relative 'cam_follow'
require_relative 'collision'
require_relative 'control'
require_relative 'cursor'
require_relative 'drawable'
require_relative 'emitter'
require_relative 'entity'
require_relative 'follow_mouse'
require_relative 'friction'
require_relative 'life'
require_relative 'physics'
require_relative 'position'
require_relative 'utility'

module Modulus

class Engine
  include Utility

  def initialize window
    @window = window

    @last_time = Gosu::milliseconds
    @time = 0

    @entities = []

    @entities_to_remove = []
    @entities_to_add = []

    @input_state = {}

    @cam_x = 0.0
    @cam_y = 0.0
    @cam_buffer = 20

    @visited_chunks = {}
    @chunk_size = 1000

    @proc_gen = Proc.new {}
  end

  def update
    new_time = Gosu::milliseconds
    dt = (new_time-@last_time).to_f*MILLISECOND
    @time += dt
    @last_time = new_time

    @entities.each_with_index do |e, i|
      @me = e
      @my_index = i

      e.update dt, @time
    end

    proc_gen

    @entities_to_add.each do |e|
      @entities << e
    end
    @entities_to_add.clear

    @entities_to_remove.each do |e|
      @entities.delete e
    end
    @entities_to_remove.clear
  end

  def draw
    @entities.each do |e|
      e.draw @window
    end
  end

  def button_down id
    @input_state[id] = true
  end

  def button_up id
    @input_state[id] = false
  end

  def down? id
    @input_state[id]
  end

  def pause
    @input_state.clear
  end

  def unpause
    @input_state.clear
    @last_time = Gosu::milliseconds
  end

  def cam_x
    @cam_x
  end

  def cam_y
    @cam_y
  end

  def cam_x= x
    @cam_x = x
  end

  def cam_y= y
    @cam_y = y
  end

  def each_entity
    @entities.each do |e|
      yield e
    end
  end

  def each_entity_after_me
    @entities[@my_index..-1].each do |e|
      yield e
    end
  end

  def remove_me
    remove_entity @me
  end

  def remove_entity e
    @entities_to_remove << @me
  end

  def add_entity e
    @entities_to_add << e
  end

  def screen2world x, y
    [x-@window.width/2+@cam_x, y-@window.height/2+@cam_y]
  end

  def world2screen x, y
    [x+@window.width/2-@cam_x, y+@window.height/2-@cam_y]
  end

  def mouse_in_world_coords
    screen2world @window.mouse_x, @window.mouse_y
  end

  def mouse_in_screen_coords
    [@window.mouse_x, @window.mouse_y]
  end

  def proc_gen
    if @proc_gen
      x1,y1 = screen2world(-@cam_buffer,-@cam_buffer)
      x2,y2 = screen2world(@window.width+@cam_buffer,@window.height+@cam_buffer)

      x1 = x1.to_i / @chunk_size
      y1 = y1.to_i / @chunk_size
      x2 = x2.to_i / @chunk_size
      y2 = y2.to_i / @chunk_size

      @visited_chunks.each do |k,v|
        v[:active] = false
      end

      (x1..x2).each do |xi|
        (y1..y2).each do |yi|
          unless @visited_chunks[[xi,yi]]
            # @engine.add_chunk([xi,yi])
            @proc_gen.call(xi, yi, @chunk_size)
            @visited_chunks[[xi,yi]] = {:active => true}
          else
            @visited_chunks[[xi,yi]][:active] = true
          end
        end
      end

      # @visited_chunks.each do |k,v|
      #   @engine.activate_chunk k, v[:active]
      # end
    end
  end

  def on_proc_gen &block
    @proc_gen = block
  end

end

end
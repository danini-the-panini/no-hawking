require 'gosu'
require_relative 'matrix_hacks'
require_relative 'component'
require_relative 'entity'
require_relative 'transformable'
require_relative 'transform'
require_relative 'renderable'
require_relative 'renderer'
require_relative 'timepiece'
require_relative 'camera'

module Garbage

  $last_id = 0

  def self.make_id
    $last_id += 1
  end

  # TODO: Put this thing in its own class
  # in fact, I think it needs to be replaced by something
  # like a linked-hash? I dunno...
  class EntityHash
    def initialize
      @values = Hash.new { |h,k| h[k] = [] }
      @values_to_add = Hash.new { |h,k| h[k] = [] }
    end

    def add tag, object
      @values_to_add[tag] << object
    end

    def values
      @values
    end

    def sync
      @values_to_add.each do |k,v|
        @values[k].concat v
        v.clear
      end
    end
  end

  class Engine
    def initialize window
      @window = window
      @entities = EntityHash.new
      @entities_by_component = Hash.new { |h,k| h[k] = [] }
      @drawable_entities = []
      @inputs = []
      @timepiece = Timepiece.new
      @camera = make_camera
      add_entity :main_camera, @camera
    end

    def window
      @window
    end

    def button_down id
      @inputs[id] = true
      each_entity do |e|
        e.button_down id
      end
    end

    def button_down? id
      @inputs[id]
    end

    def button_up id
      @inputs[id] = false
      each_entity do |e|
        e.button_up id
      end
    end

    def update
      @timepiece.tick
      @entities.values.each do |k,v|
        v.delete_if do |e|
          e.update

          if e.destroyed?
            e.each_component do |comp|
              component_removed e, comp
            end
          end
          e.destroyed?
        end
      end
      @entities.sync
    end

    def time
      @timepiece.time
    end

    def delta
      @timepiece.delta
    end

    def draw
      @window.translate(
          @camera.camera.world2screen_x(0),
          @camera.camera.world2screen_y(0)) do
        @drawable_entities.delete_if do |e|
          e.draw
          e.destroyed?
        end
      end
    end

    def add_entity tag, entity
      entity.added_to self
      entity.each_component do |comp|
        component_added entity, comp
      end
      @entities.add tag, entity
      if entity.is_a? Renderable
        @drawable_entities << entity
      end
    end

    def component_added entity, component
      @entities_by_component[component] << entity
    end

    def component_removed entity, component
      @entities_by_component[component].delete entity
    end

    def remove_entity entity
      entity.destroy!
    end

    def find_by_tag tag
      @entities.values[tag]
    end

    def each_with_component component
      each_entity do |e|
        yield e if e.has_component(component)
      end
    end

    def main_camera
      @camera
    end

    def main_camera= camera
      @camera = camera
    end

    private

      def each_entity
        @entities.values.each do |k,v|
          v.each do |e|
            yield e
          end
        end
      end

      def make_camera
        camera = Transformable.new
        camera.add_component :camera, Camera.new # TODO: add stuff?
        camera
      end

  end
end

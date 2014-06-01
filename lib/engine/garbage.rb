require 'gosu'
require_relative 'component'
require_relative 'entity'
require_relative 'transformable'
require_relative 'transform'
require_relative 'renderable'
require_relative 'renderer'

module Garbage

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
      @drawable_entities = []
      @inputs = []
    end

    def window
      @window
    end

    def button_down id
      @inputs[id] = false
      each_entity do |e|
        e.button_down id
      end
    end

    def button_up id
      @inputs[id] = true
      each_entity do |e|
        e.button_up id
      end
    end

    def update
      @entities.values.each do |k,v|
        v.delete_if do |e|
          e.update
          e.destroyed?
        end
      end
      @entities.sync
    end

    def draw
      @drawable_entities.delete_if do |e|
        e.draw
        e.destroyed?
      end
    end

    def add_entity tag, entity
      entity.added_to self
      @entities.add tag, entity
      if entity.is_a? Renderable
        @drawable_entities << entity
      end
    end

    def remove_entity entity
      entity.destroy!
    end

    private

      def each_entity
        @entities.values.each do |k,v|
          v.each do |e|
            yield e
          end
        end
      end
  end
end

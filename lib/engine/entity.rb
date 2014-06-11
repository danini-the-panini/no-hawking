require_relative 'garbage.rb'

module Garbage
  class Entity
    def initialize
      @id = Garbage.make_id
      @components = {}
    end

    def id
      @id
    end

    def add_component name, component
      @engine.component_added self, name if @engine
      component.added_to self, @engine
      @components[name] = component
      (class << self; self; end).class_eval do
        define_method name do
          component
        end
      end
    end

    def remove_component name
      @engine.component_removed self, name if @engine
      @components.delete name
      remove_method name
    end

    def on_hit other
      each_component_value do |comp|
        comp.on_hit other
      end
    end

    %w(update).each do |meth|
      define_method meth do
        each_component_value do |comp|
           comp.send meth
        end
      end
    end

    %w(button_down button_up).each do |meth|
      define_method meth do |id|
        each_component_value do |comp|
          comp.send meth, id
        end
      end
    end

    def has_component? comp
      @components.has_key? comp
    end

    def destroy!
      @destroyed = true
    end

    def revive!
      @destroyed = false
    end

    def destroyed?
      @destroyed
    end

    def added_to engine
      @engine = engine
      each_component_value do |comp|
        comp.added_to self, engine
      end
    end

    def each_component
      @components.keys.each do |comp|
        yield comp
      end
    end

    private

      def each_component_value
        @components.values.each do |comp|
          yield comp
        end
      end

  end
end

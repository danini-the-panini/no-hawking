module Garbage
  class Entity
    def initialize
      @components = {}
    end

    def add_component name, component
      component.added_to self, @engine
      @components[name] = component
      self.class.send(:define_method, name) do
        component
      end
    end

    def remove_component name
      @components.delete name
      remove_method name
    end

    %w(update).each do |meth|
      define_method meth do
        each_component do |comp|
           comp.send meth
        end
      end
    end

    %w(button_down button_up).each do |meth|
      define_method meth do |id|
        each_component do |comp|
          puts "calling #{meth}"
          comp.send meth, id
        end
      end
    end

    def has_component comp
      @component.has_key? comp
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
      each_component do |comp|
        comp.added_to self, engine
      end
    end

    private

      def each_component
        @components.values.each do |comp|
          yield comp
        end
      end
  end
end

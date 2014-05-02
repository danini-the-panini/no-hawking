require 'gosu'

module Tentative

  MILLISECOND = 0.001

  class Engine

    def initialize
      @last_time = Gosu::milliseconds
      @time = 0

      @systems = {:update => {}, :draw => {}, :once => {},
        :btn_up => {}, :btn_down => {}}

      @nodes = {}
      @next_id = 0

      @entities_to_add = []
      @entities_to_remove = []

      @input_state = {}
    end

    def add_system type, name, node, &block
      @nodes[node] ||= {}
      @systems[type][name] = [node, block]
      self
    end

    def remove_system type, name
      @systems[type].delete name
    end

    def add_entity entity, *nodes
      if @updating
        @entities_to_add << [entity, nodes]
      else
        id = gen_id
        entity[:id] = id
        nodes.each do |node|
          # tentatively assume user has created system to handle node
          @nodes[node][id] = entity
        end
      end
    end

    def remove_entity entity, *nodes
      if @updating
        @entities_to_remove << [entity, nodes]
      else
        if nodes.include? :all
          @nodes.each do |node|
            node.delete entity[:id]
          end
        else
          nodes.each do |node|
            @nodes[node].delete entity[:id]
          end
        end
      end
    end

    def each_entity node
      @node[node].each do |id, e|
        yield e
      end
    end

    def button_down id
      @systems[:btn_down].each do |node, block|
        @nodes[node].each do |i, e|
          block.call(e, id)
        end
      end
      @input_state[id] = true
    end

    def button_up id
      @systems[:btn_up].each do |node, block|
        @nodes[node].each do |i, e|
          block.call(e, id)
        end
      end
      @input_state[id] = false
    end

    def update
      new_time = Gosu::milliseconds
      dt = (new_time-@last_time).to_f*MILLISECOND
      @time += dt
      @last_time = new_time

      @updating = true

      @systems[:update].each do |node, block|
        @nodes[node].each do |i, e|
          block.call(e, dt, t)
        end
      end

      @updating = false

      @entities_to_add.each do |entity,nodes|
        add_entity entity, *nodes
      end
      @entities_to_add.clear

      @entities_to_remove.each do |entity,nodes|
        remove_entity entity, *nodes
      end
      @entities_to_remove.clear

    end

    def draw
      @systems[:draw].each do |node, block|
        @nodes[node].each do |i, e|
          block.call(e)
        end
      end
    end

    private

      def gen_id
        id = @next_id
        @next_id += 1
        id
      end

  end

end
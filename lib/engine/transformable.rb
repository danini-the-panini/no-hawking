require_relative 'entity'
require_relative 'transform'

module Garbage
  class Transformable < Entity
    def initialize
      super
      @transform = Transform.new
    end

    def transform
      @transform
    end
  end
end

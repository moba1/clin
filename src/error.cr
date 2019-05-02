require "colorize"

module Clin::Error
  class DimensionError < Exception
    @n : Int32
    @m : Int32

    def initialize(@n, @m)
    end

    def message
      title = "Dimension Error".colorize(:red).mode(:bold)
      content = "lhs_dim(#{@n}) != rhs_dim(#{@m})".colorize(:white).mode(:bold)
      "#{title}: #{content}"
    end
  end
end
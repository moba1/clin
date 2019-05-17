require "../../error"

module Clin::Value
  abstract class Matrix(T)
    private def initialize; end

    abstract def dim
    abstract def [](key)
  end
end
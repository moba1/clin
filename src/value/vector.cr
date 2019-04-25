require "../error"

module Clin::Value
  module Vector(T, N)
    def initialize
      @buffer = Pointer(T).malloc(N)
    end

    def unsafe_fetch(index : Int)
      @buffer[index]
    end

    # def +(other : V)
    #   rhs = 
    #   V.new(value.map_with_index {|x, i| x + rhs[i]})
    # end

    # def +
    #   V.new value
    # end

    # def -
    #   typeof(self).new value.map {|x| -x}
    # end

    # def to_s
    #   "#{typeof(self)}#{value.to_a}"
    # end

    # def inspect(io)
    #   io << to_s
    # end

    # abstract def transpose : Vector
    # abstract def *(other : Vector)
    # abstract def *(other : Number)
    # abstract def /(other : Number)
  end

  class ColumnVector(T, N)
    include Vector(T, N)

    # def transpose : Vector
    #   RowVector.new(value)
    # end

    # def *(other : RowVector(T, N))
    #   # TODO
    # end

    # def *(other : Number)
    #   ColumnVector.new(value.map {|x| x * other})
    # end

    # def /(other : Number)
    #   ColumnVector.new(value.map {|x| x / other})
    # end
  end

  class RowVector(T, N)
    # include Vector(RowVector, T, N)

    # def transpose : Vector
    #   ColumnVector.new(value)
    # end

    # def *(other : ColumnVector(T, N))
    #   rhs = other.value
    #   other.value.map_with_index {|x, i| x * rhs[i]}.reduce(0) {|acc, i| acc + i}
    # end

    # def *(other : Number)
    #   RowVector.new(value.map {|x| x * other})
    # end

    # def /(other : Number)
    #   RowVector.new(value.map {|x| x / other})
    # end
  end
end
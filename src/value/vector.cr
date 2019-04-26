require "../error"

macro implement_vector_initializer(vec_type)
  macro [](*args)
    %array = Clin::Value::{{vec_type}}(typeof(\{\{*args}}), \{\{args.size}}).new
    \{% for arg, i in args %}
      %array[\{\{i}}] = \{\{arg}}
    \{% end %}
    %array
  end
end

module Clin::Value
  abstract class Vector(T, N)
    include Indexable(T)

    def initialize
      @buffer = Pointer(T).malloc(N)
    end

    def unsafe_fetch(index : Int)
      @buffer[index]
    end

    def []=(index : Int, value : T)
      @buffer[index] = value
    end

    def size
      N
    end

    def self.new(&block : Int32 -> T)
      cvec = self.new
      N.times do |i|
        cvec[i] = yield i
      end
      cvec
    end

    def self.new(array : Array(T))
      self.new {|i| array[i] }
    end

    # def +(other : self)
    #   self.map_with_index {|x, i| x + other[i]}
    # end

    # def +
    #   V.new value
    # end

    # def -
    #   typeof(self).new value.map {|x| -x}
    # end

    # def to_s
    #   "#{typeof(self)}#{@buffer}"
    # end

    def inspect(io)
      io << to_s
    end

    # abstract def transpose : Vector
    # abstract def *(other : Vector)
    # abstract def *(other : Number)
    # abstract def /(other : Number)
  end

  class ColumnVector(T, N) < Vector(T, N)
    implement_vector_initializer ColumnVector

    def to_s
      str = "#{typeof(self)}[\n"
      N.times do |i|
        str += "  #{self[i]}#{i + 1 == N ? "" : ","}\n"
      end
      str += "]"
    end

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

  class RowVector(T, N) < Vector(T, N)
    implement_vector_initializer RowVector

    def to_s
      str = "#{typeof(self)}[\n  "
      N.times do |i|
        str += "#{self[i]}#{i + 1 == N ? "" : ", "}"
      end
      str += "\n]"
    end

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
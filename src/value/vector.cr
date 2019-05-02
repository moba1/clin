require "big"
require "../error"

module Clin::Value
  module Vector(T)
    include Indexable(T)

    @dim : Int32

    def initialize(array : Array(T))
      @dim = array.size
      @buffer = Pointer(T).malloc(@dim)

      @dim.times do |i|
        @buffer[i] = array[i]
      end
    end

    def unsafe_fetch(index : Int)
      @buffer[index]
    end

    def size
      @dim
    end

    def dim
      @dim
    end

    def []=(index : Int, value : T)
      @buffer[index] = value
    end

    def inspect(io)
      io << to_s
    end
  end

  struct ColumnVector(T)
    include Vector(T)

    def to_s
      str = "#{typeof(self)}[\n"
      @dim.times do |i|
        str += "  #{self[i]}#{i + 1 == @dim ? "" : ","}\n"
      end
      str += "]"
    end

    def transpose
      RowVector.new(self.to_a)
    end
  end

  struct RowVector(T)
    include Vector(T)

    def to_s
      str = "#{typeof(self)}[\n  "
      @dim.times do |i|
        str += "#{self[i]}#{i + 1 == @dim ? "" : ", "}"
      end
      str += "\n]"
    end

    def transpose
      ColumnVector.new(self.to_a)
    end
  end

  {% begin %}
    {% for klass in %w(ColumnVector RowVector) %}
      struct {{klass.id}}(T)
        macro [](*args)
          %array = Clin::Value::{{klass.id}}.new(\{\{args}}.to_a)
        end

        def +
          {{klass.id}}.new(self.to_a)
        end

        def -
          new_vec = {{klass.id}}.new(self.to_a)
          new_vec.dim.times do |i|
            new_vec[i] = -new_vec[i]
          end
          new_vec
        end

        def +(other : {{klass.id}}(U)) forall U
          if other.dim != @dim
            raise Clin::Error::DimensionError.new(dim, other.dim)
          end

          new_values = [] of T | U
          @dim.times do |i|
            new_values << self[i] + other[i]
          end
          {{klass.id}}.new(new_values)
        end

        def -(other : {{klass.id}}(U)) forall U
          other = -other
          self + other
        end
      end
    {% end %}
  {% end %}
end

{% begin %}
    {% nums = %w(Int8 Int16 Int32 Int64 Int128 UInt8 UInt16 UInt32 UInt64 UInt128 Float32 Float64 BigFloat BigInt BigRational BigDecimal) %}
    {% for num in nums %}
      {% for klass in %w(Clin::Value::ColumnVector Clin::Value::RowVector) %}
        struct {{num.id}}
          def *(other : {{klass.id}}(T)) forall T
            new_values = [] of T | self
            other.dim.times do |i|
              new_values << self * other[i]
            end
            {{klass.id}}.new(new_values)
          end
        end

        struct {{klass.id}}(T)
          def *(other : {{num.id}})
            new_values = [] of T | {{num.id}}
            self.dim.times do |i|
              new_values << self[i] * other
            end
            {{klass.id}}.new(new_values)
          end
        end

        struct {{klass.id}}(T)
          def /(other : {{num.id}})
            new_values = [] of T | {{num.id}}
            self.dim.times do |i|
              new_values << self[i] / other
            end
            {{klass.id}}.new(new_values)
          end
        end
      {% end %}
    {% end %}
  {% end %}
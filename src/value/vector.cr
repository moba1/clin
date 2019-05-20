require "big"
require "../error"

module Clin::Value
  abstract class Vector(T)
    include Indexable(T)

    getter dim : Int32

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

    def []=(index : Int, value : T)
      @buffer[index] = value
    end

    def inspect(io)
      io << to_s
    end

    abstract def transpose
    abstract def *(other)
    abstract def +(other)
    abstract def -(other)
    abstract def /(other)
    abstract def +
    abstract def -
  end

  class ColumnVector(T) < Vector(T)
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

  class RowVector(T) < Vector(T)
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

    def *(other : ColumnVector)
      if other.dim != dim
        raise Clin::Error::DimensionError.new(dim, other.dim)
      end

      res = 0
      dim.times do |i|
        res += other[i] * self[i]
      end
      res
    end
  end

  {% begin %}
    {% for klass in %w(ColumnVector RowVector) %}
      class {{klass.id}}(T)
        include Comparable({{klass.id}})

        macro [](*args)
          Clin::Value::{{klass.id}}.new(\{\{args}}.to_a)
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

        {% for op, i in %w(+ -) %}
          def {{op.id}}(other : {{klass.id}}(U)) forall U
            if other.dim != @dim
              raise Clin::Error::DimensionError.new(dim, other.dim)
            end

            new_values = [] of T | U
            @dim.times do |i|
              new_values << self[i] {{op.id}} other[i]
            end
            {{klass.id}}.new(new_values)
          end
        {% end %}

        def <=>(other : {{klass.id}}(U)) forall U
          comps = 0
          dim.times do |i|
            comp_res = self[i] <=> other[i]
            case comp_res
            when Nil
              return nil
            else
              comps |=
                if comp_res > 0
                  0x01
                elsif comp_res < 0
                  0x02
                else
                  0x04
                end
            end
          end

          case comps
          when 0x07, 0x03
            nil
          when 0x05, 0x01
            1
          when 0x02, 0x06
            -1
          when 0x04
            0
          end
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

      class {{klass.id}}(T)
        def *(other : {{num.id}})
          new_values = [] of T | {{num.id}}
          self.dim.times do |i|
            new_values << self[i] * other
          end
          {{klass.id}}.new(new_values)
        end
      end

      class {{klass.id}}(T)
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
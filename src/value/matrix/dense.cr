require "../matrix"

private macro validate_index(m, n, key)
  if {{m}} <= {{key}}[0] || {{n}} <= {{key}}[1]
    raise IndexError.new
  end
end

private macro get_address(n, i, j)
  {{n}} * {{i}} + {{j}}
end

module Clin::Value
  class DenseMatrix(T) < Matrix(T)
    @buf : Pointer(T)

    getter m
    getter n

    private def initialize(@m : Int32, @n : Int32, val : Array(Array(T)))
      @buf = Pointer(T).malloc(@m, @n)

      @m.times do |i|
        @n.times do |j|
          @buf[get_address(@n, i, j)] = val[i][j]
        end
      end
    end

    def self.new(val : Array(Array(T))) : DenseMatrix(T)
      m, n = val.size, val.first.size
      if m == 0 || n == 0 || val.any? { |row| n != row.size }
        raise ArgumentError.new("All rows are not same size")
      end

      self.new(m, n, val)
    end

    def [](key : {Int, Int}) : T
      validate_index(@m, @n, key)

      @buf[get_address(@n, key[0], key[1])]
    end

    def []=(key : {Int, Int}, val : T) : T
      validate_index(@m, @n, key)

      p key
      @buf[get_address(@n, key[0], key[1])] = val
    end

    def to_s
      buf = "#{typeof(self)}[\n"
      dig_sizes = [0] * @n

      @m.times do |i|
        @n.times do |j|
          number = @buf[i * @m + j].to_s
          dig_sizes[j] = \
            number.size > dig_sizes[j] ? number.size : dig_sizes[j]
        end
      end

      @m.times do |i|
        buf += "  "
        @n.times do |j|
          buf += sprintf("%#{dig_sizes[j]}d,", @buf[get_address(@n, i, j)])
          if j + 1 != @n
            buf += " "
          end
        end
        buf += "\n"
      end

      buf + "]"
    end

    def inspect(io)
      io << to_s
    end

    def each
      (@m * @n).times do |i|
        yield @buf[i]
      end
    end

    def to_a : Array(Array(T))
      buf = [] of Array(T)

      @m.times do |i|
        _buf = [] of T
        @n.times do |j|
          _buf << @buf[get_address(@n, i, j)]
        end
        buf << _buf
      end

      buf
    end

    def transpose : DenseMatrix(T)
      DenseMatrix.new(to_a.transpose)
    end

    def +
      DenseMatrix.new(to_a)
    end

    def -
      DenseMatrix.new(to_a.map { |row| row.map { |e| -e } })
    end

    {% for op in %w(+ -) %}
      def {{op.id}}(other : DenseMatrix(T)) : DenseMatrix(T)
        if !(other.m == @m && other.n == n)
          raise ArgumentError.new(
            "dimension is not same: {#{{@m, @n}}} != {#{{other.m, other.n}}}"
          )
        end

        DenseMatrix.new(to_a.zip(other.to_a).map { |self_row, other_row|
          self_row.zip(other_row).map { |se, oe| se {{op.id}} oe }
        })
      end
    {% end %}
  end
end
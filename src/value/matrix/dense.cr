require "../matrix"

private macro get_dim(val)
  m, n = {{val}}.size, {{val}}.first.size
  if m == 0 || n == 0
    raise ArgumentError.new("All rows are not same size")
  end
  if {{val}}.any? { |row| n != row.size }
    raise ArgumentError.new("All rows are not same size")
  end

  {m, n}
end

private macro validate_index(m, n, key)
  if {{m}} <= {{key}}[0] || {{n}} <= {{key}}[1]
    raise IndexError.new
  end
end

private macro get_address(m, i, j)
  {{m}} * {{i}} + {{j}} + ({{i}} == 0 ? 0 : 1)
end

module Clin::Value
  class DenseMatrix(T) < Matrix(T)
    @buf : Pointer(T)

    getter m
    getter n

    private def initialize(@m : Int32, @n : Int32, val : Array(Array(T)))
      @buf = Pointer(T).malloc(val.size, val.first.size)
      val.size.times do |i|
        val[i].size.times do |j|
          @buf[get_address(val.size, i, j)] = val[i][j]
        end
      end
    end

    def self.new(val : Array(Array(T))) : DenseMatrix(T)
      m, n = get_dim(val)
      self.new(m, n, val)
    end

    def [](key : {Int, Int}) : T
      validate_index(@m, @n, key)

      @buf[get_address(@m, key[0], key[1])]
    end

    def []=(key : {Int, Int}, val : T) : T
      validate_index(@m, @n, key)

      p key
      @buf[get_address(@m, key[0], key[1])] = val
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
          buf += sprintf("%#{dig_sizes[j]}d,", @buf[get_address(@m, i, j)])
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
  end
end
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

private macro val_2_buf(val)
  %buf = Pointer(T).malloc({{val}}.size, {{val}}.first.size)
  {{val}}.size.times do |i|
    {{val}}[i].size.times do |j|
      %buf[i * {{val}}.size + j] = {{val}}[i][j]
    end
  end
  %buf
end

private macro get_elem(m, n, key, buf)
  case {{key}}
  when \{Int, Int}
    if {{key}}[0] >= {{m}} || {{key}}[1] >= {{n}}
      raise IndexError.new
    end

    {{buf}}[{{key}}[0] * {{m}} + {{key}}[1]]
  else
    raise IndexError.new("index type require \{Int, Int}")
  end
end

module Clin::Value
  class DenseMatrix(T) < Matrix(T)
    @buf : Pointer(T)

    private def initialize(@m : Int32, @n : Int32, val : Array(Array(T)))
      @buf = val_2_buf(val)
    end

    def self.new(val : Array(Array(T)))
      m, n = get_dim(val)
      self.new(m, n, val)
    end

    def dim
      {@m, @n}
    end

    def [](key)
      get_elem(@m, @n, key, @buf)
    end
  end
end
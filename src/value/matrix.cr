require "../error"

# module Clin::Value
#   module Matrix(T, M, N)
#     def initialize(@data : StaticArray(T, N))
#     end

#     def value
#       @data.clone
#     end

#     def +(other : self) forall U
#       rhs = other.value
#       typeof(self).new(value.map_with_index {|x, i| x + rhs[i]})
#     end

#     def +
#       typeof(self).new value
#     end

#     def -
#       typeof(self).new value.map {|x| -x}
#     end
#   end

#   class ColumnVector(T, N)
#     include Vector(T, N)
#   end

#   class RowVector(T, N)
#     include Vector(T, N)
#   end
# end
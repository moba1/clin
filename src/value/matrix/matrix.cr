require "../../error"

module Clin::Value
  abstract class Matrix(T)
    private def initialize; end

    def dim : Hash(Symbol, Int32)
      {:row => m, :col => n}
    end

    abstract def m : Int32
    abstract def n : Int32

    abstract def [](key : {Int, Int}) : T
    abstract def []=(key : {Int, Int}, value : T) : T
    # abstract def +(other)
    # abstract def -(other)
  end
end
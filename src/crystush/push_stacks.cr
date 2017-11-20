module Crystush
  class PushStacks
    property boolean_stack : Array(Bool) = [] of Bool
    property integer_stack : Array(Int32) = [] of Int32
    property float_stack : Array(Float64) = [] of Float64
    property exec_stack : Array(String) = [] of String
    property code_stack : Array(String) = [] of String

    def to_s(io)
      io << "BOOLEAN: " << boolean_stack << "\n"
      io << "INTEGER: " << integer_stack << "\n"
      io << "FLOAT  : " << float_stack << "\n"
      io << "EXEC   : " << exec_stack << "\n"
      io << "CODE   : " << code_stack << "\n"
    end
  end
end

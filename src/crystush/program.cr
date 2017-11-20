module Crystush
  class Program

    INSTRUCTIONS = [
      "BOOLEAN.=",
      "BOOLEAN.AND",
      #"BOOLEAN.DEFINE",
      "BOOLEAN.DUP",
      "BOOLEAN.FLUSH",
      "BOOLEAN.FROMFLOAT",
      "BOOLEAN.FROMINTEGER",
      "BOOLEAN.NOT",
      "BOOLEAN.OR",
      "BOOLEAN.POP",
      #"BOOLEAN.RAND",
      #"BOOLEAN.ROT",
      #"BOOLEAN.SHOVE",
      "BOOLEAN.STACKDEPTH",
      "BOOLEAN.SWAP",
      #"BOOLEAN.YANK",
      #"BOOLEAN.YANKDUP",
      "CODE.DO",
      "CODE.DUP",
      "CODE.IF",
      "CODE.QUOTE",
      "FLOAT.%",
      "FLOAT.*",
      "FLOAT.+",
      "FLOAT.-",
      "FLOAT./",
      "FLOAT.<",
      "FLOAT.=",
      "FLOAT.>",
      "FLOAT.COS",
      #"FLOAT.DEFINE",
      "FLOAT.DUP",
      "FLOAT.FLUSH",
      "FLOAT.FROMBOOLEAN",
      "FLOAT.FROMINTEGER",
      "FLOAT.MAX",
      "FLOAT.MIN",
      "FLOAT.POP",
      #"FLOAT.RAND",
      #"FLOAT.ROT",
      #"FLOAT.SHOVE",
      "FLOAT.SIN",
      "FLOAT.STACKDEPTH",
      "FLOAT.SWAP",
      "FLOAT.TAN",
      #"FLOAT.YANK",
      #"FLOAT.YANKDUP",
      "INTEGER.%",
      "INTEGER.*",
      "INTEGER.+",
      "INTEGER.-",
      "INTEGER./",
      "INTEGER.<",
      "INTEGER.=",
      "INTEGER.>",
      #"INTEGER.DEFINE",
      "INTEGER.DUP",
      "INTEGER.FLUSH",
      "INTEGER.FROMBOOLEAN",
      "INTEGER.FROMFLOAT",
      "INTEGER.MAX",
      "INTEGER.MIN",
      "INTEGER.POP",
      #"INTEGER.RAND",
      #"INTEGER.ROT",
      #"INTEGER.SHOVE",
      "INTEGER.STACKDEPTH",
      "INTEGER.SWAP"
      #"INTEGER.YANK",
      #"INTEGER.YANKDUP",
    ]

    property program : String = ""
    property configuration : Configuration = Configuration.new

    def initialize(program : String)
      self.program = program
    end

    def evaluate(stacks = PushStacks.new) : PushStacks
      #stacks = PushStacks.new
      # See if top-level-push-code is set:
      if configuration.top_level_push_code
        # Code will be pushed onto code stack prior to execution:
        stacks.code_stack.push(program)
      end
      # http://faculty.hampshire.edu/lspector/push3-description.html
      # To execute program P:
      # Push P onto the EXEC stack:
      stacks.exec_stack.push(program)
      # Loop until the exec stack is empty:
      loop do
        if configuration.debug_each_step
          puts stacks
        end
        break if stacks.exec_stack.empty?
        token = stacks.exec_stack.pop
        if configuration.debug_each_step
          puts "Executing: #{token}"
        end
        if is_instruction(token)
          # if the first item is a single instruction:
          # execute
          execute_instruction(token, stacks)
        elsif is_list(token)
          # else if it's a list:
          # push all the items it contains onto the exec stack individually
          list = breakup_list(token)
          loop do
            break if list.empty?
            stacks.exec_stack.push list.pop
          end 
        else
          # Else if it's a literal
          # push onto proper stack
          # TODO: Get other types in here
          # TODO: Handle float check better
          if token == "TRUE"
            stacks.boolean_stack.push true
          elsif token == "FALSE"
            stacks.boolean_stack.push false
          elsif token.includes? "."
            stacks.float_stack.push token.to_f
          else
            stacks.integer_stack.push token.to_i
          end
        end

      end
      return stacks
    end

    def breakup_list (list_token : String) : Array(String)
      #puts "Breaking up list '#{list_token}'"
      # This will remove the start/end parenthesis
      list_string = list_token.sub(/^\s*\(\s*/,"").sub(/\s*\)\s*$/,"")
      #puts "Stripped first and last parenthesis:"
      #puts "Resulting list: '#{list_string}'"
      # Now that the wrapping parenthesis are gone:
      list = list_string.split
      result_list = [] of String
      stack = [] of String
      paren_count = 0
      # We can't just split and return
      loop do
        break if list.empty?
        t = list.shift
        if t == "("
          stack.push t
          paren_count += 1
        elsif t == ")"
          stack.push t
          paren_count -= 1
          if paren_count == 0
            result_list.push stack.join(" ")
            stack = [] of String
          end
        else
          if paren_count > 0
            stack.push t
          else
            result_list.push t
          end
        end
      end

      return result_list
    end

    def is_instruction(token : String) : Bool
      return INSTRUCTIONS.includes? token
    end

    def is_list(token : String) : Bool
      return token[0] == '('
    end

    def execute_instruction(instruction : String, stacks : PushStacks)
      #puts "Executing instruction: #{instruction}"
      if instruction.starts_with? "BOOLEAN."
        execute_boolean_instruction(instruction, stacks)
      elsif instruction.starts_with? "CODE."
        execute_code_instruction(instruction, stacks)
      elsif instruction.starts_with? "FLOAT."
        execute_float_instruction(instruction, stacks)
      elsif instruction.starts_with? "INTEGER."
        execute_integer_instruction(instruction, stacks)
      else
        raise "Unknown instruction: #{instruction}"
      end
    end

    def execute_boolean_instruction(instruction : String, stacks : PushStacks)
      if instruction == "BOOLEAN.="
        # We need 2 booleans:
        return if stacks.boolean_stack.size < 2
        rhs = stacks.boolean_stack.pop
        lhs = stacks.boolean_stack.pop
        result = lhs == rhs
        stacks.boolean_stack.push result
      elsif instruction == "BOOLEAN.AND"
        # We need 2 booleans:
        return if stacks.boolean_stack.size < 2
        rhs = stacks.boolean_stack.pop
        lhs = stacks.boolean_stack.pop
        result = lhs && rhs
        stacks.boolean_stack.push result
      elsif instruction == "BOOLEAN.DUP"
        # We need a boolean:
        return if stacks.boolean_stack.size < 1
        result = stacks.boolean_stack.pop
        # Push twice:
        stacks.boolean_stack.push result
        stacks.boolean_stack.push result
      elsif instruction == "BOOLEAN.FLUSH"
        stacks.boolean_stack.clear
      elsif instruction == "BOOLEAN.FROMFLOAT"
        # We need a float:
        return if stacks.float_stack.size < 1
        lhs = stacks.float_stack.pop
        result = lhs != 0.0 # False if 0.0
        stacks.boolean_stack.push result
      elsif instruction == "BOOLEAN.FROMINTEGER"
        # We need a integer:
        return if stacks.integer_stack.size < 1
        lhs = stacks.integer_stack.pop
        result = lhs != 0 # False if 0
        stacks.boolean_stack.push result
      elsif instruction == "BOOLEAN.NOT"
        # We need a boolean:
        return if stacks.boolean_stack.size < 1
        result = stacks.boolean_stack.pop
        stacks.boolean_stack.push !result
      elsif instruction == "BOOLEAN.OR"
        # We need 2 booleans:
        return if stacks.boolean_stack.size < 2
        rhs = stacks.boolean_stack.pop
        lhs = stacks.boolean_stack.pop
        result = lhs || rhs
        stacks.boolean_stack.push result
      elsif instruction == "BOOLEAN.POP"
        # We need a boolean:
        return if stacks.boolean_stack.size < 1
        stacks.boolean_stack.pop
      elsif instruction == "BOOLEAN.STACKDEPTH"
        result = stacks.boolean_stack.size
        stacks.integer_stack.push result
      elsif instruction == "BOOLEAN.SWAP"
        return if stacks.boolean_stack.size < 2
        rhs = stacks.boolean_stack.pop
        lhs = stacks.boolean_stack.pop
        stacks.boolean_stack.push rhs
        stacks.boolean_stack.push lhs
      else
        raise "Unknown instruction: #{instruction}"
      end
    end

    def execute_code_instruction(instruction : String, stacks : PushStacks)
      if instruction == "CODE.DO"
        return if stacks.code_stack.size < 1
        result = stacks.code_stack.pop
        stacks.exec_stack.push result
      elsif instruction == "CODE.DUP"
        return if stacks.code_stack.size < 1
        result = stacks.code_stack.pop
        stacks.code_stack.push result
        stacks.code_stack.push result
      elsif instruction == "CODE.IF"
        return if stacks.code_stack.size < 2
        return if stacks.boolean_stack.size < 1
        rhs = stacks.code_stack.pop
        lhs = stacks.code_stack.pop
        bool = stacks.boolean_stack.pop
        # See if the boolean is true:
        result = bool ? lhs : rhs
        stacks.exec_stack.push result
      elsif instruction == "CODE.QUOTE"
        # Takes the next expression for execution, and puts onto the code stack
        # So, do we have an item on the exec stack?
        return if stacks.exec_stack.size < 1
        # Pop from exec, push onto code:
        result = stacks.exec_stack.pop
        stacks.code_stack.push result
      else
        raise "Unknown instruction: #{instruction}"
      end
    end

    def execute_float_instruction(instruction : String, stacks : PushStacks)
      if instruction == "FLOAT.%"
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        # The top float should not be 0 (acts as noop otherwise)
        return if stacks.float_stack.last == 0
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        result = lhs % rhs
        stacks.float_stack.push result
      elsif instruction == "FLOAT.*"
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        result = lhs * rhs
        stacks.float_stack.push result
      elsif instruction == "FLOAT.+"
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        result = lhs + rhs
        stacks.float_stack.push result
      elsif instruction == "FLOAT.-"
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        result = lhs - rhs
        stacks.float_stack.push result
      elsif instruction == "FLOAT./"
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        # The top float should not be 0 (acts as noop otherwise)
        return if stacks.float_stack.last == 0
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        result = lhs / rhs
        stacks.float_stack.push result
      elsif instruction == "FLOAT.<"
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        result = lhs < rhs
        stacks.boolean_stack.push result
      elsif instruction == "FLOAT.="
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        result = lhs == rhs
        stacks.boolean_stack.push result
      elsif instruction == "FLOAT.>"
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        result = lhs > rhs
        stacks.boolean_stack.push result
      elsif instruction == "FLOAT.COS"
        # We need 1 float:
        return if stacks.float_stack.size < 1
        rhs = stacks.float_stack.pop
        result = Math.cos(rhs)
        stacks.float_stack.push result
      elsif instruction == "FLOAT.DUP"
        # We need 1 float:
        return if stacks.float_stack.size < 1
        result = stacks.float_stack.pop
        # Push twice
        stacks.float_stack.push result
        stacks.float_stack.push result
      elsif instruction == "FLOAT.FLUSH"
        stacks.float_stack.clear
      elsif instruction == "FLOAT.FROMBOOLEAN"
        # We need 1 boolean:
        return if stacks.boolean_stack.size < 1
        rhs = stacks.boolean_stack.pop
        result = rhs ? 1.0 : 0.0
        stacks.float_stack.push result
      elsif instruction == "FLOAT.FROMINTEGER"
        # We need 1 integer:
        return if stacks.integer_stack.size < 1
        rhs = stacks.integer_stack.pop
        result = rhs.to_f
        stacks.float_stack.push result
      elsif instruction == "FLOAT.MAX"
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        result = Math.max(lhs,rhs)
        stacks.float_stack.push result
      elsif instruction == "FLOAT.MIN"
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        result = Math.min(lhs,rhs)
        stacks.float_stack.push result
      elsif instruction == "FLOAT.POP"
        # We need 1 float:
        return if stacks.float_stack.size < 1
        stacks.float_stack.pop
      elsif instruction == "FLOAT.SIN"
        # We need 1 float:
        return if stacks.float_stack.size < 1
        rhs = stacks.float_stack.pop
        result = Math.sin(rhs)
        stacks.float_stack.push result
      elsif instruction == "FLOAT.STACKDEPTH"
        result = stacks.float_stack.size
        stacks.integer_stack.push result
      elsif instruction == "FLOAT.SWAP"
        # We need 2 floats:
        return if stacks.float_stack.size < 2
        rhs = stacks.float_stack.pop
        lhs = stacks.float_stack.pop
        stacks.float_stack.push rhs
        stacks.float_stack.push lhs
      elsif instruction == "FLOAT.TAN"
        # We need 1 float:
        return if stacks.float_stack.size < 1
        rhs = stacks.float_stack.pop
        result = Math.tan(rhs)
        stacks.float_stack.push result
      else
        raise "Unknown instruction: #{instruction}"
      end
    end

    def execute_integer_instruction(instruction : String, stacks : PushStacks)
      if instruction == "INTEGER.%"
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        # The top integer should not be 0 (acts as noop otherwise)
        return if stacks.integer_stack.last == 0
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        result = lhs % rhs
        stacks.integer_stack.push result
      elsif instruction == "INTEGER.*"
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        result = lhs * rhs
        stacks.integer_stack.push result
      elsif instruction == "INTEGER.+"
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        result = lhs + rhs
        stacks.integer_stack.push result
      elsif instruction == "INTEGER.-"
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        result = lhs - rhs
        stacks.integer_stack.push result
      elsif instruction == "INTEGER./"
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        # The top integer should not be 0 (acts as noop otherwise)
        return if stacks.integer_stack.last == 0
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        result = lhs / rhs
        stacks.integer_stack.push result
      elsif instruction == "INTEGER.<"
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        result = lhs < rhs
        stacks.boolean_stack.push result
      elsif instruction == "INTEGER.="
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        result = lhs == rhs
        stacks.boolean_stack.push result
      elsif instruction == "INTEGER.>"
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        result = lhs > rhs
        stacks.boolean_stack.push result
      elsif instruction == "INTEGER.DUP"
        # We need 1 integer:
        return if stacks.integer_stack.size < 1
        result = stacks.integer_stack.pop
        stacks.integer_stack.push result
        stacks.integer_stack.push result
      elsif instruction == "INTEGER.FLUSH"
        stacks.integer_stack.clear
      elsif instruction == "INTEGER.FROMBOOLEAN"
        # We need 1 boolean:
        return if stacks.boolean_stack.size < 1
        rhs = stacks.boolean_stack.pop
        result = rhs ? 1 : 0
        stacks.integer_stack.push result
      elsif instruction == "INTEGER.FROMFLOAT"
        # We need 1 float:
        return if stacks.float_stack.size < 1
        rhs = stacks.float_stack.pop
        result = rhs.to_i
        stacks.integer_stack.push result
      elsif instruction == "INTEGER.MAX"
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        result = Math.max(lhs,rhs)
        stacks.integer_stack.push result
      elsif instruction == "INTEGER.MIN"
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        result = Math.min(lhs,rhs)
        stacks.integer_stack.push result
      elsif instruction == "INTEGER.POP"
        # We need 1 integer:
        return if stacks.integer_stack.size < 1
        stacks.integer_stack.pop
      elsif instruction == "INTEGER.STACKDEPTH"
        result = stacks.integer_stack.size
        stacks.integer_stack.push result
      elsif instruction == "INTEGER.SWAP"
        # We need 2 integers:
        return if stacks.integer_stack.size < 2
        rhs = stacks.integer_stack.pop
        lhs = stacks.integer_stack.pop
        stacks.integer_stack.push rhs
        stacks.integer_stack.push lhs
      else
        raise "Unknown instruction: #{instruction}"
      end
    end

  end
end

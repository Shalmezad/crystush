require "./spec_helper"
require "./instructions/**"

describe Crystush do
  # TODO: Break up instructions into seperate spec files by type

  # region GENERAL PUSH
  it "should handle nested instructions" do
    Crystush::Program.new("( 1 ( 6 2 INTEGER./ ) INTEGER.+ )").evaluate.integer_stack.pop.should eq(4)
  end

  it "should break a list up properly" do
    program = "( 1 ( ( 6 ) ( 2 ) INTEGER./ ) INTEGER.+ ( 5 ) )"
    list = Crystush::Program.new(program).breakup_list(program)
    list[0].should eq "1"
    list[1].should eq "( ( 6 ) ( 2 ) INTEGER./ )"
    list[2].should eq "INTEGER.+"
    list[3].should eq "( 5 )"

    program = "( ( ( ( 1 ) ) ) )"
    list = Crystush::Program.new(program).breakup_list(program)
    list[0].should eq "( ( ( 1 ) ) )"
    program = list[0]
    list = Crystush::Program.new(program).breakup_list(program)
    list[0].should eq "( ( 1 ) )"

  end

  it "should handle every listed instructions" do
    Crystush::Program::INSTRUCTIONS.each do |instruction|
      Crystush::Program.new(instruction).evaluate
    end
  end

  it "should properly evaluate simple example 1" do
    program = "( 2 3 INTEGER.* 4.1 5.2 FLOAT.+ TRUE FALSE BOOLEAN.OR )"
    stacks = Crystush::Program.new(program).evaluate
    # BOOLEAN STACK: ( TRUE )
    stacks.boolean_stack.size.should eq(1)
    stacks.boolean_stack[0].should eq(true)
    # CODE STACK: ( ( 2 3 INTEGER.* 4.1 5.2 FLOAT.+ TRUE FALSE BOOLEAN.OR ) )
    stacks.code_stack.size.should eq(1)
    stacks.code_stack[0].should eq("( 2 3 INTEGER.* 4.1 5.2 FLOAT.+ TRUE FALSE BOOLEAN.OR )")
    # FLOAT STACK: ( 9.3 )
    stacks.float_stack.size.should eq(1)
    stacks.float_stack[0].should eq(9.3)
    # INTEGER STACK: ( 6 )
    stacks.integer_stack.size.should eq(1)
    stacks.integer_stack[0].should eq(6)

  end

  it "should properly evaluate simple example 2" do
    # "scrambled-looking arithmetic:
    program = "( 5 1.23 INTEGER.+ ( 4 ) INTEGER.- 5.67 FLOAT.* )"
    stacks = Crystush::Program.new(program).evaluate
    # CODE STACK: ( ( 5 1.23 INTEGER.+ ( 4 ) INTEGER.- 5.67 FLOAT.* ) )
    stacks.code_stack.size.should eq(1)
    stacks.code_stack[0].should eq("( 5 1.23 INTEGER.+ ( 4 ) INTEGER.- 5.67 FLOAT.* )")
    # FLOAT STACK: ( 6.9741 )
    stacks.float_stack.size.should eq(1)
    stacks.float_stack[0].should eq(6.9741)
    # INTEGER STACK: ( 1 )
    stacks.integer_stack.size.should eq(1)
    stacks.integer_stack[0].should eq(1)
  end


  it "should properly evaluate tiny program 1" do
    # Here is a tiny program that adds an integer pre-loaded onto the stack to itself:
    program = "( INTEGER.DUP INTEGER.+ )"
    preload_stacks = Crystush::PushStacks.new
    preload_stacks.integer_stack.push 4
    stacks = Crystush::Program.new(program).evaluate(preload_stacks)
    stacks.integer_stack.size.should eq(1)
    stacks.integer_stack[0].should eq(8)
  end

  it "should handle a slightly more complicated tiny program" do
    # The following does the same thing [adds integer to self]
    # in a slightly more complicate way
    program = "( CODE.QUOTE ( INTEGER.DUP INTEGER.+ ) CODE.DO )"
    preload_stacks = Crystush::PushStacks.new
    preload_stacks.integer_stack.push 4
    stacks = Crystush::Program.new(program).evaluate(preload_stacks)
    stacks.integer_stack.size.should eq(1)
    stacks.integer_stack[0].should eq(8)

  end

  it "should handle the recursive factorial example" do
    program = "( CODE.QUOTE ( INTEGER.POP 1 ) CODE.QUOTE ( CODE.DUP INTEGER.DUP 1 INTEGER.- CODE.DO INTEGER.* ) INTEGER.DUP 2 INTEGER.< CODE.IF )"
    preload_stacks = Crystush::PushStacks.new
    preload_stacks.integer_stack.push 4
    stacks = Crystush::Program.new(program).evaluate(preload_stacks)
    stacks.integer_stack.size.should eq(1)
    stacks.integer_stack[0].should eq(24)
  end

  # endregion


end

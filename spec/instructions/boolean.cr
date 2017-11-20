describe Crystush do
  it "should handle the boolean type" do
    stack = Crystush::Program.new("TRUE").evaluate.boolean_stack
    stack.size.should eq(1)
    stack.pop.should eq(true)

    stack = Crystush::Program.new("FALSE").evaluate.boolean_stack
    stack.size.should eq(1)
    stack.pop.should eq(false)
  end

  it "should properly handle BOOLEAN.=" do
    # Should NOOP, leaving top item:
    Crystush::Program.new("( TRUE BOOLEAN.= )").evaluate.boolean_stack.pop.should eq(true)
    Crystush::Program.new("( FALSE BOOLEAN.= )").evaluate.boolean_stack.pop.should eq(false)
    # Should return true (equal)
    Crystush::Program.new("( TRUE TRUE BOOLEAN.= )").evaluate.boolean_stack.pop.should eq(true)
    Crystush::Program.new("( FALSE FALSE BOOLEAN.= )").evaluate.boolean_stack.pop.should eq(true)
    # Should return false (unequal)
    Crystush::Program.new("( TRUE FALSE BOOLEAN.= )").evaluate.boolean_stack.pop.should eq(false)
    Crystush::Program.new("( FALSE TRUE BOOLEAN.= )").evaluate.boolean_stack.pop.should eq(false)
  end

  it "should properly handle BOOLEAN.AND" do
    # Should NOOP, leaving top item:
    Crystush::Program.new("( TRUE BOOLEAN.AND )").evaluate.boolean_stack.pop.should eq(true)
    Crystush::Program.new("( FALSE BOOLEAN.AND )").evaluate.boolean_stack.pop.should eq(false)
    # Should return true (both true)
    Crystush::Program.new("( TRUE TRUE BOOLEAN.AND )").evaluate.boolean_stack.pop.should eq(true)
    # Should return false (both not true:)
    Crystush::Program.new("( FALSE FALSE BOOLEAN.AND )").evaluate.boolean_stack.pop.should eq(false)
    Crystush::Program.new("( TRUE FALSE BOOLEAN.AND )").evaluate.boolean_stack.pop.should eq(false)
    Crystush::Program.new("( FALSE TRUE BOOLEAN.AND )").evaluate.boolean_stack.pop.should eq(false)
  end

  it "should properly handle BOOLEAN.DUP" do
    stack = Crystush::Program.new("( TRUE BOOLEAN.DUP )").evaluate.boolean_stack
    stack.size.should eq(2)
    stack.pop.should eq(true)
    stack.pop.should eq(true)
    stack = Crystush::Program.new("( FALSE BOOLEAN.DUP )").evaluate.boolean_stack
    stack.size.should eq(2)
    stack.pop.should eq(false)
    stack.pop.should eq(false)
  end

  it "should properly handle BOOLEAN.FLUSH" do
    stack = Crystush::Program.new("( FALSE BOOLEAN.FLUSH)").evaluate.boolean_stack
    stack.size.should eq(0)
  end

  it "should properly handle BOOLEAN.FROMFLOAT" do
    # False if the top is 0.0:
    stacks = Crystush::Program.new("( 0.0 BOOLEAN.FROMFLOAT )").evaluate
    stacks.float_stack.size.should eq(0)
    stacks.boolean_stack.size.should eq(1)
    stacks.boolean_stack.pop.should eq(false)
    # true otherwise:
    stacks = Crystush::Program.new("( 0.1 BOOLEAN.FROMFLOAT )").evaluate
    stacks.float_stack.size.should eq(0)
    stacks.boolean_stack.size.should eq(1)
    stacks.boolean_stack.pop.should eq(true)
  end

  it "should properly handle BOOLEAN.SWAP" do
    stack = Crystush::Program.new("( FALSE TRUE BOOLEAN.SWAP)").evaluate.boolean_stack
    stack.size.should eq(2)
    stack[0].should eq(true)
    stack[1].should eq(false)
  end
end

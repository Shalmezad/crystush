describe Crystush do
  it "should do basic arithmetic with floats" do
    Crystush::Program.new("( 1.0 2.0 FLOAT.+ )").evaluate.float_stack.pop.should eq(3)
    Crystush::Program.new("( 3.0 2.0 FLOAT.- )").evaluate.float_stack.pop.should eq(1)
    Crystush::Program.new("( 3.0 2.0 FLOAT.* )").evaluate.float_stack.pop.should eq(6)
    Crystush::Program.new("( 6.0 2.0 FLOAT./ )").evaluate.float_stack.pop.should eq(3)
    Crystush::Program.new("( 5.0 2.0 FLOAT.% )").evaluate.float_stack.pop.should eq(1)
  end

  it "should properly handle FLOAT.FROMBOOLEAN" do
    # Should NOOP, leaving top item:
    stacks = Crystush::Program.new("( 1.0 FLOAT.FROMBOOLEAN )").evaluate
    stacks.boolean_stack.size.should eq(0)
    stacks.float_stack.size.should eq(1)
    stacks.float_stack[0].should eq(1)
    # Should put 0.0:
    stacks = Crystush::Program.new("( FALSE FLOAT.FROMBOOLEAN )").evaluate
    stacks.boolean_stack.size.should eq(0)
    stacks.float_stack.size.should eq(1)
    stacks.float_stack[0].should eq(0.0)
    # Should put 1.0:
    stacks = Crystush::Program.new("( TRUE FLOAT.FROMBOOLEAN )").evaluate
    stacks.boolean_stack.size.should eq(0)
    stacks.float_stack.size.should eq(1)
    stacks.float_stack[0].should eq(1.0)
  end


end

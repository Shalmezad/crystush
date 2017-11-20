describe Crystush do

  it "should do basic arithmetic with integers" do
    Crystush::Program.new("( 1 2 INTEGER.+ )").evaluate.integer_stack.pop.should eq(3)
    Crystush::Program.new("( 3 2 INTEGER.- )").evaluate.integer_stack.pop.should eq(1)
    Crystush::Program.new("( 3 2 INTEGER.* )").evaluate.integer_stack.pop.should eq(6)
    Crystush::Program.new("( 6 2 INTEGER./ )").evaluate.integer_stack.pop.should eq(3)
  end

  it "should handle integer division with fractional result" do
    Crystush::Program.new("( 5 2 INTEGER./ )").evaluate.integer_stack.pop.should eq(2)
  end

  it "should handle integer division by 0" do
    # Per documentation, if the top item is 0, acts as NOOP
    Crystush::Program.new("( 4 0 INTEGER./ )").evaluate.integer_stack.should eq([4,0])
  end

  it "should ignore instruction if not enough values" do
    Crystush::Program.new("( 0 INTEGER./ )").evaluate.integer_stack.pop.should eq(0)
  end

end

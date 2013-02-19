require 'spec_helper'
require 'sexptitah'
describe '#to_sexp method' do
  it 'Object should respond to to_sexp' do
    Object.new.should respond_to(:to_sexp)
  end
  it 'should return a string' do
    String.should === Object.new.to_sexp
  end
end

describe Cons do
  before(:each) do
    @cons = Cons.new 1, nil
  end
  it "should have a 'chain' class method." do
    Cons.should respond_to(:chain)
  end

  describe 'Cons@chain' do
    it "should create a Cons chain with correct car and cdr" do
      @chain = Cons.chain(1,2,nil)
      @chain.should == Cons[1,Cons[2, nil]]
      @chain = Cons.chain(1,2,3,4)
      @chain.should == Cons[1,Cons[2,Cons[3, 4]]]
    end
  end

  it "should have a 'list' class method." do
    Cons.should respond_to(:list)
  end

  it "should correctly create a proper list." do
    proper_list = Cons.list(1, 2, 3, 4)
    proper_list.should == Cons[1, Cons[2, Cons[3, Cons[4, nil]]]]
  end

  describe
  it "should have a 'car' method." do
    @cons.should respond_to(:car)
  end

  it "should have a 'cdr' method." do
    @cons.should respond_to(:cdr)
  end

  it "should have a [] class method." do
    Cons.should respond_to(:'[]')
  end

  it "should have [] instance method." do
    @cons.should respond_to(:'[]')
  end

  describe "Cons#[]" do
    it "list[n] should return the nth element." do
      a = [1, 2, 3, 4, 5, 6]
      l = Cons.list(*a)
      a.each_with_index { |el, idx| l[idx].should == el }
    end
  end
end

require 'spec_helper'
require 'sexptitah'

describe 'List and Conses' do
  describe NilClass do
    it "should include Enumerable." do
      NilClass.should include(Enumerable)
    end
    it "should include ConsMixin." do
      NilClass.should include(ConsMixin)
    end
    it "should have 0 length." do
      nil.length.should be(0)
    end
    it "should be nil if reversed." do
    end
    describe "ConsMixin methods" do
      it "should return nil for all the methods but 'length'." do
        nil.lreverse.should be(nil)
        nil.assoc(:foo).should be(nil)
        nil.rassoc(:bar).should be(nil)
        nil.mapcar { |x| x.class }.should be(nil)
        nil.maplist { |x| x.class }.should be(nil)
      end
    end
  end

  describe ConsMixin do
    it "should have a 'length' method." do
      ConsMixin.method_defined?(:length).should be(true)
    end
    it "should have a 'mapcar' method." do
      ConsMixin.method_defined?(:mapcar).should be(true)
    end
    it "should have a 'maplist' method." do
      ConsMixin.method_defined?(:maplist).should be(true)
    end
    it "should have a 'assoc' method." do
      ConsMixin.method_defined?(:assoc).should be(true)
    end
    it "should have a 'rassoc' method." do
      ConsMixin.method_defined?(:rassoc).should be(true)
    end
  end

  describe "Enumerable#to_list" do
    it "should be defined" do
      Enumerable.method_defined?(:to_list).should be(true)
    end
    it "should correctly convert enumerables to Cons lists" do
      [1,2,3,4,5].to_list.should == Cons.list(1,2,3,4,5)
      (1..5).to_list.should == Cons.list(1,2,3,4,5)
    end
    describe "Hash#to_list" do
      it "should correctly convert Hash tables to alists" do
        hl = {:a => 1, :b => 2, 'foo' => 'bar', 4 => :foo}.to_list
        hl.should == Cons.list(Cons[:a, 1], Cons[:b, 2], Cons['foo', 'bar'], Cons[4, :foo])
      end
    end
  end


  describe Cons do
    before(:each) do
      @array = [1, 2, 3, 4, 5, 6]
      @cons = Cons.new 1, nil
      @list = Cons.list(*@array)
    end

    describe 'Mixins' do
      it "should include ConsMixin" do
        Cons.should include(ConsMixin)
      end
      it "should be Enumerable" do
        Cons.should include(Enumerable)
      end
    end
    describe 'Class Methods' do
      describe 'Cons.chain' do
        it "should have a 'chain' class method." do
          Cons.should respond_to(:chain)
        end
        it "should create a Cons chain with correct car and cdr" do
          chain = Cons.chain(1,2,nil)
          chain.should == Cons[1,Cons[2, nil]]
          chain = Cons.chain(1,2,3,4)
          chain.should == Cons[1,Cons[2,Cons[3, 4]]]
        end
      end

      describe "Cons.list" do
        it "should have a 'list' class method." do
          Cons.should respond_to(:list)
        end

        it "should correctly create a proper list." do
          proper_list = Cons.list(1, 2, 3, 4)
          proper_list.should == Cons[1, Cons[2, Cons[3, Cons[4, nil]]]]
        end
      end

      it "should have a [] class method." do
        Cons.should respond_to(:'[]')
      end
    end

    describe "Instance Methods" do
      it "should have a 'car' method." do
        @cons.should respond_to(:car)
      end

      it "should have a 'cdr' method." do
        @cons.should respond_to(:cdr)
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

      it "should have a 'each' method" do
        @cons.should respond_to(:each)
      end

      it "should have a mapl method" do
        @cons.should respond_to(:mapl)
      end

      describe "Cons#length" do
        it "should count the elements of a proper list correctly." do
          100.times do |i|
            (1..i).to_list.length.should be(i)
          end
        end
      end

      describe "Cons#lreverse" do
        it "should correctly reverse the elements of a list" do
          @list.lreverse.should == @array.reverse.to_list
        end
      end

      describe "Cons#mapcar" do
        it "should correctly apply a block to each element of a proper list" do
          @list.mapcar { |x| x*x }.to_a.should == [1,2,3,4,5,6].map { |x| x*x }
        end
      end

      describe "Cons#maplist" do
        it "should correctly apply a block to each consecutive cdr of a proper list" do
          @list.maplist { |x| x.length }.to_a.should == [6,5,4,3,2,1]
        end
      end

      describe "Cons#assoc" do
        it "should correctly find the first cons inside a list whose car is == to the specified key" do
          alist = Cons.list(Cons[:a, 1], Cons[:b, 2], Cons[:c, 3], Cons[:a, 10])
          alist.assoc(:a).should == Cons[:a, 1]
          alist.assoc(:b).should == Cons[:b, 2]
          alist.assoc(:c).should == Cons[:c, 3]
        end
      end
      describe "Cons#rassoc" do
        it "should correctly find the first cons inside a list whose cdr is == to the specified key" do
          alist = Cons.list(Cons[:a, 1], Cons[:b, 2], Cons[:c, 3], Cons[:d, 1])
          alist.rassoc(1).should == Cons[:a, 1]
          alist.rassoc(2).should == Cons[:b, 2]
          alist.rassoc(3).should == Cons[:c, 3]
        end
      end

      describe "Cons#to_s" do
        it "should correctly render a proper list" do
          s = Cons.list(:a, 1, Cons.list(2,3), [3,4], "foobar baz").to_s
          s.should == '(:a 1 (2 3) [3, 4] "foobar baz")'
        end
        it "should correctly render a dotted list" do
          Cons.chain(1,2,3).to_s.should == '(1 2 . 3)'
        end
      end
      describe "Cons#inspect" do
        it "should correctly render a proper list" do
          s = Cons.list(:a, 1, Cons.list(2,3), [3,4], "foobar baz").inspect
          s.should == '#<Cons (:a 1 #<Cons (2 3)> [3, 4] "foobar baz")>'
        end
        it "should correctly render a dotted list" do
          Cons.chain(1,2,3).inspect.should == '#<Cons (1 2 . 3)>'
        end
      end
    end
  end

end

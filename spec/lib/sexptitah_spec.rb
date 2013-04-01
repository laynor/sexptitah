require 'spec_helper'
require 'sexptitah'
describe 'Sexptitah' do
  describe 'Symbol#keyword' do
    foo = :foo
    foo.keyword.should == ":#{foo}".intern
  end

  describe '#to_sexp method' do
    it 'Object should respond to to_sexp.' do
      Object.new.should respond_to(:to_sexp)
    end
    it 'should return a string.' do
      String.should === Object.new.to_sexp
    end

    it 'nil.to_sexp => "nil"' do
      nil.to_sexp.should == "nil"
    end

    describe 'Numbers' do
      it "should correctly render integers" do
        123.to_sexp.should == '123'
      end
    end

    describe Symbol do
      it "should correctly render symbols" do
        :foo.to_sexp.should == 'foo'
        :FOO.to_sexp.should == 'FOO'
      end
      it "should correctly render symbols with spaces" do
        :'foo bar'.to_sexp.should == 'foo\ bar'
        :"foo\nbar".to_sexp.should == "foo\\\nbar"
        :"foo\tbar".to_sexp.should == "foo\\\tbar"
      end
    end

    describe Cons do
      it "should correctly render a proper list" do
        Cons.list(1,2,3,4).to_sexp.should == '(1 2 3 4)'
      end

      it "should correctly render a cons cell" do
        Cons[1,2].to_sexp.should == '(1 . 2)'
      end
      it "should correctly render an improper list" do
        Cons.chain(1,2,3,4).to_sexp.should == '(1 2 3 . 4)'
      end
    end

    describe 'Enumerables' do
      it "should display an enumerable as a list" do
        (3..7).to_sexp.should == '(3 4 5 6 7)'
      end
    end

    describe Array do
      it "should render an array correctly" do
        [1,2,3,4,5].to_sexp.should == '[1 2 3 4 5]'
      end
    end

    describe Hash do
      before :each do
        @h = {1=>2, :foo => Cons.list(1,2,3)}
      end
      it "should correctly render a hash as a plist"
        # TODO find a good interface
      it "should correclty render a hash as an alist" do
        @h.to_sexp.should == '((1 . 2) (foo 1 2 3))'
      end
    end
  end

end

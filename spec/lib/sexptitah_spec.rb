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

    describe 'Strings' do
      it "should correctly render strings" do
        "foobar".to_sexp.should == '"foobar"'
        "foo\nbar".to_sexp.should == '"foo\nbar"'
        "foo\tbar".to_sexp.should == '"foo\tbar"'
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

      it "should correctly render this list: '(1 2 (3 \"asdf\") foo :bar [1 2 3])'" do
        Cons.list(1, 2, Cons.list(3, "asdf"), :foo, :bar.keyword, [1, 2, 3]).to_sexp.should ==
         "(1 2 (3 \"asdf\") foo :bar [1 2 3])"
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

    describe 'Boolean' do
      it "true => true" do
        true.to_sexp.should == 'true'
      end
      it "false => nil" do
        false.to_sexp.should == 'nil'
      end
    end
  end

  describe "Deserialization" do
    describe SexptitahParser do
      def parse(str)
        SexptitahParser.new(str).parse
      end
      it "should correctly parse a number" do
        parse("12").should == [12]
      end
      it "should correctly parse a string" do
        parse('"foobar\n"').should == ["foobar\n"]
      end
      it "should correctly parse a symbol" do
        parse('foobar').should == [:foobar]
      end
      it "should correctly parse nil" do
        parse("nil").should == [nil]
      end
      it "should correctly parse symbols with dashes" do
        parse("foo-bar").should == [:foo_bar]
      end
      it "should correctly parse symbols with spaces" do
        parse('foo\ bar').should == [:"foo\\ bar"]
      end
      it 'should correclty parse a keyword symbol' do
        parse(':foobar').should == [:':foobar']
      end
      it 'should correclty parse a list' do
        parse('(foo bar 1 "baz")').should == [Cons.list(:foo, :bar, 1, "baz")]
      end
      it 'should correctly parse an array' do
        parse('[foo bar 1 "baz"]').should == [[:foo, :bar, 1, "baz"]]
      end
      it 'should correctly parse a nested list' do
        parse('(foo bar (1 baz) 2)').should == [Cons.list(:foo, :bar, Cons.list(1, :baz), 2)]
      end
      it 'should correctly parse nested arrays' do
        parse('[[1 2][3 4]]').should == [[[1,2],[3,4]]]
      end

      it 'should correctly parse a mixed array/list' do
        parse('[(1 2) [3 4] (5 [6 (7)])]').should ==
          [[Cons.list(1,2), [3,4], Cons.list(5, [6, Cons.list(7)])]]
      end

      it 'should correctly parse a cons cell' do
        parse('(1 . 2)').should == [Cons[1, 2]]
      end

      it 'should correctly handle a dotted proper list' do
        parse('(1 . (2 3))').should == [Cons.list(1, 2, 3)]
      end

      it 'should raise an error if more than a sexp follows the dot.' do
        expect { parse('(1 . 2 3)') }.to raise_error
      end

      it 'should correctly parse a cons whose cdr is an array.' do
        parse('(1 . [2 3])').should == [Cons[1, [2,3]]]
      end

      it 'should correctly parse a cons whose cdr is nil.' do
        parse('(1 . nil)').should == [Cons[1, nil]]
      end

      it 'should raise an error if a dot is found outside of a list' do
        expect { parse('1 . 2') }.to raise_error
        expect { parse('[1 . 2]') }.to raise_error
      end

    end
  end

end

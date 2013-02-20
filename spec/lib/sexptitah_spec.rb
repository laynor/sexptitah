require 'spec_helper'
require 'sexptitah'
describe '#to_sexp method' do
  it 'Object should respond to to_sexp.' do
    Object.new.should respond_to(:to_sexp)
  end
  it 'should return a string.' do
    String.should === Object.new.to_sexp
  end
end

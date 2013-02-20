# require 'sexptitah/version'

class Object
  def to_sexp
    inspect
  end
end

# Requires these methods:
#  each
#  mapl
module ConsMixin
  def length
    i = 0
    each do
      i += 1
    end
    i
  end

  def lreverse
    l = nil
    each do |el|
      l = Cons[el, l]
    end
    l
  end

  def mapcar &block
    # this is faster than the direct implementation using 'each'.
    map(&block).to_list
  end

  def maplist
    a = []
    self.mapl do |cdr|
      a << yield(cdr)
    end
    a.to_list
  end

  def rassoc(key)
    find { |x| x.cdr == key }
  end

  def assoc(key)
    find { |x| x.car == key }
  end
end

class Array
  def to_cons_chain
    b = self[0..-2]
    l = self[-1]
    b.reverse_each do |x|
      l = Cons[x, l]
    end
    l
  end
end

module Enumerable
  def to_list
    l = nil
    self.reverse_each do |x|
      l = Cons[x, l]
    end
    l
  end
end

class Hash
  alias :old_to_list :to_list
  def to_list
    map { |k, v| Cons[k,v] }.to_list
  end
end

class NilClass
  include Enumerable
  include ConsMixin
  def car
    nil
  end

  def cdr
    nil
  end

  def each
    nil
  end

  def mapl
    nil
  end
end

class Cons
  attr_accessor :car, :cdr
  include Enumerable
  include ConsMixin

  def initialize(car, cdr)
    @car, @cdr = car, cdr
  end

  def each
    p = self
    while Cons === p.cdr
      yield p.car
      p = p.cdr
    end
    yield p.car
  end

  def ==(other_cons)
    other_cons.car == @car && other_cons.cdr == @cdr
  end

  def [](n)
    p = self
    n.times do
      p = p.cdr
    end
    p.car
  end

  def self.chain(*args)
    args.to_cons_chain
  end

  def self.list(*args)
    args.to_list
  end

  def self.[](car, cdr)
    Cons.new car, cdr
  end

  def to_s
    s = '('
    p = self
    while Cons === p.cdr
      s << p.car.send(Cons === p.car ? :to_s : :inspect) + " "
      p = p.cdr
    end
    s << p.car.send(Cons === p.car ? :to_s : :inspect)
    if p.cdr != nil
      s << " . #{p.cdr.inspect}"
    end
    s << ')'
  end

  def inspect
    s = '#<Cons ('
    p = self
    while Cons === p.cdr
      s << p.car.inspect + " "
      p = p.cdr
    end
    s << p.car.inspect
    if p.cdr != nil
      s << " . #{p.cdr.inspect}"
    end
    s << ')>'
  end

  def mapl
    p = self
    while Cons === p
      yield p
      p = p.cdr
    end
  end
end

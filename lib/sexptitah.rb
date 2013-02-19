require 'sexptitah/version'

class Object
  def to_sexp
    inspect
  end
end

class Cons
  attr_accessor :car, :cdr
  def initialize(car, cdr)
    @car, @cdr = car, cdr
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

  def self.chain(car, *args, lastcdr)
    if args.empty?
      Cons[car, lastcdr]
    else
      Cons[car, self.chain(*(args + [lastcdr]))]
    end
  end

  def self.list(*args)
    self.chain(*(args + [nil]))
  end

  def self.[](car, cdr)
    Cons.new car, cdr
  end

  def to_s
    s = '('
    p = self
    while Cons === p.cdr
      s << p.car.to_s + " "
      p = p.cdr
    end
    s << p.car.to_s
    if p.cdr != nil
      s << " . #{p.cdr}"
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
end

require 'sexptitah/version'
require 'sexptitah/list'

class Object
  def to_sexp
    inspect
  end
end

class NilClass
  def to_sexp
    'nil'
  end
end

module Enumerable
  def to_sexp
    to_list.to_sexp
  end
end

class Symbol
  def to_sexp
    to_s.gsub(/(\s)/, '\\\\\1')
  end

  def keyword
    ":#{to_s}".intern
  end
end

class Cons
  def to_sexp
    s = '('
    p = self
    while Cons === p.cdr
      s << p.car.to_sexp + " "
      p = p.cdr
    end
    s << p.car.to_sexp
    if p.cdr != nil
      s << " . #{p.cdr.to_sexp}"
    end
    s << ')'
  end
end

class Array
  def to_sexp
    '[' + map{ |x| x.to_sexp }.join(' ')+ ']'
  end
end

class Hash
  def to_sexp
    to_list.to_sexp
  end
end

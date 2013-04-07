require 'sexptitah/version'
require 'sexptitah/list'

#####################
## sexp serialization
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

class FalseClass
  def to_sexp
    'nil'
  end
end

######################################
## sexp deserialization
##
## lists -> Cons
## Arrays -> Array
##
## Parsing code adapted from sexpistol

require 'strscan'

class SexptitahParser < StringScanner

  def initialize(string)
    unless(string.count('(') == string.count(')'))
      raise Exception, "Missing closing parentheses"
    end
    super(string)
  end

  @@matching_paren = {
    '(' => ')',
    '{' => '}',
    '[' => ']'
  }

  # expected: the expected closing paren or delimiter

  def parse(level=0, expected=nil, list=false)
    chain = false
    exp = []
    while true
      case fetch_token
      when '('
        exp << parse(level + 1, @@matching_paren[@token], true)
      when '[', '{'
        exp << parse(level + 1, @@matching_paren[@token])
      when ')', ']', '}'
        raise RuntimeError.new("Mismatched closing paren")  if @token != expected
        break
      when :"'"
        case fetch_token
        when '(', '[', '{' then exp << [:quote].concat([parse(level+1, @@matching_paren[@token])])
        else exp << [:quote, @token]
        end
      when :'.'
        if list
          rest = parse(level, ')')
          raise RuntimeError.new('Syntax error - more than one sexp after dot.')  if rest.length > 1
          exp = exp + rest
          chain = true
        else
          raise RuntimeError.new('Syntax error - dot outside of a list.')
        end
      when :nil
        exp << nil
      when String, Fixnum, Bignum, Float, Symbol
        exp << @token
      when nil
        break
      end
    end
    list ? exp.send(chain ? :to_cons_chain : :to_list) : exp
  end

  def fetch_token
    skip(/\s+/)
    return nil if(eos?)

    @token =
    # Match parentheses
    if scan(/[\[\{\(\)\}\]]/)
      matched
    # Match a string literal
    elsif scan(/"([^"\\]|\\.)*"/)
      eval(matched)
    # Match a float literal
    elsif scan(/[\-\+]? [0-9]+ ((e[0-9]+) | (\.[0-9]+(e[0-9]+)?))/x)
      matched.to_f
    # Match an integer literal
    elsif scan(/[\-\+]?[0-9]+/)
      matched.to_i
    # Match a comma (for comma quoting)
    elsif scan(/'/)
      matched.to_sym
    # Match a symbol
    elsif scan(/((\\\s)|[^\s\(\)]|)+/)
      matched.gsub('-', '_').to_sym
    # If we've gotten here then we have an invalid token
    else
      near = scan %r{.{0,20}}
      raise "Invalid character at position #{pos} near '#{near}'."
    end
  end

end

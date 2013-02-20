require 'benchmark'
$:.unshift '../lib'
require 'sexptitah'
class Numeric
  def commify(dec='.', sep=',')
    num = to_s.sub(/\./, dec)
    dec = Regexp.escape dec
    num.reverse.gsub(/(\d\d\d)(?=\d)(?!\d*#{dec})/, "\\1#{sep}").reverse
  end
end

N = 1_000_000
NS = N.commify
$range = (1..N)
$array = $range.to_a
$hash = Hash[(1..N/2).zip(N/2 + 1..N)]
$list_1000 = (1..1000).to_list
$array_1000 = (1..1000).to_a

Benchmark.bmbm do |bm|
  bm.report("Array#to_list(#{NS} Fixnums) 10x") do
    10.times do
      $list = $array.to_list
    end
  end
  bm.report("Hash#to_list(#{(N/2).commify} Fixnum keys and values) 10x") do
    10.times do
      $alist = $hash.to_list
    end
  end

  bm.report("Range#to_list(1..#{NS}) 10x") do
    10.times do
      $range.to_list
    end
  end

  bm.report("Array#map{ |x| x*x } (#{NS} Fixnums) 10x") do
    10.times do
      $foo = $array.map { |x| x*x }
    end
  end

  bm.report("Cons#map{ |x| x*x } (#{NS} Fixnums) 10x") do
    10.times do
      $foo = $list.map { |x| x*x }
    end
  end

  bm.report("Cons#mapcar { |x| x*x } (#{NS} Fixnums) 10x") do
    10.times do
      $foo = $list.mapcar { |x| x*x }
    end
  end

  n = 5000
  am = (1..n).to_a
  bm.report("Handmade maplist f(a) = sum(a) on array (#{n} Fixnums) 10x") do
    10.times do
      foo = am
      res = []
      while foo != [] do
        res << foo.reduce(:+)
        foo = foo[1..-1]
      end
    end
  end
  al = am.to_list
  bm.report("Cons#maplist f(a) = sum(a) (#{n} Fixnums) 10x") do
    10.times do
      $foo = al.maplist { |cdr| cdr.reduce(:+) }
    end
  end
end

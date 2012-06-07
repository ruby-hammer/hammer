require 'benchmark'

count = 20_000_000

class A
  define_method(:a) { 1+1 }
  class_eval "def b; 1+1; end"
end

a = A.new

Benchmark.bm(10) do |b|
  b.report('define') do
    count.times do
      a.a
    end
  end
  b.report('eval') do
    count.times do
      a.b
    end
  end

end
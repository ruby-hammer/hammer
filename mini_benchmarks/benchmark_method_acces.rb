require 'benchmark'

count = 10000000

class A
  def a
    1+1
  end
end

class B < A; end
class C < B; end
class D < C; end

b = Class.new A
c = Class.new b
d = Class.new c

Benchmark.bmbm(20) do |b|
  b.report('A') do
    obj = A.new
    count.times do
      obj.a
    end
  end
  b.report('D') do
    obj = D.new
    count.times do
      obj.a
    end
  end  
  b.report('d') do
    obj = d.new
    count.times do
      obj.a
    end
  end
end
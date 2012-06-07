require 'benchmark'

count = 2000000

class A
  def a
    b
  end

  def b
    1+1
  end
end

Benchmark.bm(10) do |b|
  b.report('a') do
    a = A.new
    count.times do
      a.a
    end
  end
  b.report('b') do
    a = A.new
    count.times do
      a.b
    end
  end


end
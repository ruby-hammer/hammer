require 'benchmark'

count = 30000000


Benchmark.bmbm(20) do |b|
  b.report('if') do
    count.times do |i|
      if i % 2 == 0
        1+1
      end
    end
  end
  b.report('?') do
    count.times do |i|
      i % 2 == 0 ? 1+1 : nil
    end
  end
  b.report('&&') do
    count.times do |i|
      i % 2 == 0 && 1+1
    end
  end
end
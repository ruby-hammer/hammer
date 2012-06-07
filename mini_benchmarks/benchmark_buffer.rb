require 'benchmark'

count = 2000

Benchmark.bm(10) do |b|
  b.report('string') do
    count.times do
      buf = ''
      count.times do
        buf << 'a string'
      end
    end
  end

  b.report('array') do
    count.times do
      buf = []
      count.times do
        buf << 'a string'
      end
      buf.join
    end
  end

  require 'stringio'
  b.report('stringio') do
    count.times do
      buf = StringIO.new
      count.times do
        buf << 'a string'
      end
    end
  end

end
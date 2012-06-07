require 'benchmark'

count = 2500

Benchmark.bmbm(10) do |b|
  b.report('str') do
    count.times do
      buf = ''
      count.times do
        buf << 'a string'
      end
    end
  end

  b.report('const') do
    str = 'a string'
    count.times do
      buf = ''
      count.times do
        buf << str
      end
    end
  end

  b.report('frozen') do
    str = 'a string'.freeze
    count.times do
      buf = ''
      count.times do
        buf << str
      end
    end
  end


end
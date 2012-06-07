require 'benchmark'

count = 1000

Benchmark.bmbm(15) do |b|
  #  b.report('<<') do
  #    count.times do
  #      buf = ''
  #      count.times do
  #        100.times { buf << '  ' }
  #      end
  #    end
  #  end
  #
  #  b.report('*') do
  #    count.times do
  #      buf = ''
  #      count.times do
  #        buf << '  ' * 100
  #      end
  #    end
  #  end

  #  b.report('multiple <<') do
  #    count.times do
  #      buf = ''
  #      count.times do
  #        a = 'middle'
  #        buf << ' ' << a << '=' << 'asd'
  #      end
  #    end
  #  end
  #
  #  b.report('#{}') do
  #    count.times do
  #      buf = ''
  #      count.times do
  #        a = 'middle'
  #        buf << " #{a}=#{'asd'}"
  #      end
  #    end
  #  end

  b.report('computed') do
    space = '  '
    count.times do
      buf = ''
      count.times do |i|
        buf << space * i%50
      end
    end
  end

  b.report('precomputed') do
    spaces = Array.new(50) {|i| '  '*i }
    count.times do
      buf = ''
      count.times do |i|
        buf << spaces[i%50]
      end
    end
  end

  b.report('precomputed2') do
    spaces = '  '*50
    count.times do
      buf = ''
      count.times do |i|
        buf << spaces[0, (i%50)*2]
      end
    end
  end


end
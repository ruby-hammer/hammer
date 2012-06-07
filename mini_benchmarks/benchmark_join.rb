require 'benchmark'

count = 2000000
#count = 1


Benchmark.bmbm(20) do |b|
  classes = %w{a b laslkjd askjda}
  space   = ' '
  b.report('join') do
    str = ''
    count.times do
      str << classes.join(space)
    end
  end
  b.report('loop') do
    str = ''
    count.times do
      classes.each_with_index do |c, i|
        str << space if i > 0
        str << c
      end
    end
  end
  b.report('loop2') do
    str = ''
    count.times do
      str << classes[0]
      1.upto(classes.size-1) do |i|
        str << space << classes[i]
      end
    end
  end
end

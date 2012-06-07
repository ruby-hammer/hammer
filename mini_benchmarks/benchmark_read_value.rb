require 'benchmark'

count = 20000000


class A

  def initialize
    @i = 'a'
  end

  def m
    'a'
  end

  C = 'a'

end

Benchmark.bmbm(20) do |b|
  b.report('method') do
    A.new.instance_eval do
      count.times do
        tmp = m
      end
    end
  end
  b.report('ivar') do
    A.new.instance_eval do
      count.times do
        tmp = @i
      end
    end
  end
  b.report('const') do
    A.new.instance_eval do
      count.times do
        tmp = C
      end
    end
  end
end
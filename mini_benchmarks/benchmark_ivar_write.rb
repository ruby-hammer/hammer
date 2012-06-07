require 'benchmark'

count = 20000000


class A

  attr_accessor :a

  def aa=(v)
    @a = v
  end
end

Benchmark.bm(20) do |b|
  b.report('writer') do
    a = A.new
    count.times do
      a.a = 1
    end
  end
  b.report('customwriter') do
    a = A.new
    count.times do
      a.aa = 1
    end
  end
  b.report('eval') do
    a = A.new
    count.times do
      a.instance_eval { @a = 1 }
    end
  end
end
require 'benchmark'

class A
  def a_yield
    10.times do
      yield
    end
  end

  def instance(&block)
    10.times do
      block.call
    end
  end

  def a_yield_block_given?
    10.times do
      yield if block_given?
    end
  end

  def instance_nil_test(&block)
    10.times do
      block.call if block
    end
  end

  def a_instance_eval(&block)
    10.times do
      instance_eval &block
    end
  end
end

a = A.new
#p a.a_instance_eval { p self, a; p(lambda { self }.call, a) }

count = 1000000

Benchmark.bm(20) do |b|
  b.report('a_yield') do
    a = A.new
    count.times do
      a.a_yield { 1 + 1 }
    end
  end

  b.report('a_yield_block_given?') do
    a = A.new
    count.times do
      a.a_yield_block_given?{ 1 + 1 }
    end
  end

  b.report('instance') do
    a = A.new
    count.times do
      a.instance { 1 + 1 }
    end
  end

  b.report('instance_nil_test') do
    a = A.new
    count.times do
      a.instance_nil_test{ 1 + 1 }
    end
  end

  b.report('a_instance_eval') do
    a = A.new
    count.times do
      a.a_instance_eval { 1 + 1 }
    end
  end

end
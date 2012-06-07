require 'benchmark'
require 'ostruct'

count = 20000

A_DATA  = { }
alfabet = ('a'..'z').to_a
1000.times do |i|
  A_DATA[i.to_s.gsub(/\d/) { |d| alfabet[d.to_i] }] = i
end

class B
  A_DATA.each do |k, v|
    const_set(:"#{k.capitalize}", v)
    class_variable_set(:"@@#{k}", v)
  end

  def initialize
    A_DATA.each do |k, v|
      instance_variable_set(:"@#{k}", v)
    end
  end

  def cvar(count, keys)
    eval <<-RUBY
      sum = 0
      #{count}.times do
        #{keys.map { |k| "sum += @@#{k}" }.join("\n") }
      end
    RUBY
  end

  module Cclass

  end

end

Benchmark.bmbm(10) do |b|
  keys = A_DATA.keys
  b.report('hash') do
    sum = 0
    count.times do
      keys.each { |k| sum += A_DATA[k] }
    end
  end
  b.report('ivar') do
    bi = B.new
    bi.instance_eval <<-RUBY
      sum = 0
      #{count}.times do
        #{keys.map { |k| "sum += @#{k}" }.join("\n") }
      end
    RUBY
  end
  b.report('cvar') do
    bi = B.new
    bi.cvar(count, keys)
  end
  b.report('const in') do
    B.module_eval <<-RUBY
      sum = 0
      #{count}.times do
        #{keys.map { |k| "sum += #{k.capitalize}" }.join("\n") }
      end
    RUBY
  end
  b.report('const out') do
    eval <<-RUBY
      sum = 0
      #{count}.times do
        #{keys.map { |k| "sum += B::#{k.capitalize}" }.join("\n") }
      end
    RUBY
  end
  b.report('const child') do
    B::Cclass.module_eval <<-RUBY, __FILE__, __LINE__ +1
      sum = 0
      #{count}.times do
        #{keys.map { |k| "sum += B::#{k.capitalize}" }.join("\n") }
      end
    RUBY
  end
  #store = OpenStruct.new A_DATA
  #b.report('openstruct') do
  #  sum = 0
  #  instance_eval <<-RUBY, __FILE__, __LINE__ +1
  #    #{count}.times do
  #      #{keys.map { |k| "sum += store.#{k}" }.join("\n") }
  #    end
  #  RUBY
  #end
end

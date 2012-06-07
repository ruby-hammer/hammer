require 'bundler/setup'
require 'hammer_builder'
require 'active_support/json'
require 'yajl'
require 'benchmark'


class AComponent
  attr_reader :id, :text, :arr

  def initialize
    @id   = 'c1643215746'
    @text = 'asd as asd'
    @arr  = Array.new(10) { |i| "lkj lsj ljd lkj #{i}" }
  end

  def as_json(opt = nil)
    { :id   => id,
      :text => text,
      :arr  => arr }
  end

  #def to_json
  #  { :id => id }.to_json
  #end

  def content(b)
    b.div.id(id) do
      b.p :class => 'left', :content => text
      b.ul do
        arr.each { |v| b.li.my_li v }
      end
    end
  end
end


count     = 10000
component = AComponent.new
pool      = HammerBuilder::Pool.new HammerBuilder::Standard
pool.get.to_html!

Benchmark.bmbm(10) do |b|
  b.report('yajl') do
    ActiveSupport::JSON.engine = :yajl
    count.times do
      component.to_json
    end
  end

  b.report('yajl direct') do
    count.times do
      Yajl.dump component.as_json
    end
  end

  b.report('json') do
    ActiveSupport::JSON.engine = :json_gem
    count.times do
      component.to_json
    end
  end

  b.report('json direct') do
    count.times do
      JSON.generate component.as_json
    end
  end

  b.report('hammer_builder') do
    count.times do
      pool.get.render(component, :content).to_html!
    end
  end
end

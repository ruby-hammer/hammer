# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'benchmark'
require 'ruby-prof'

describe 'Hash benchmark' do

  let :data do
    [ {:asd => false, :Ad => 154},
      [Object.new, Object.new],
      OpenStruct.new(:asd => 's', :asdasdads=> 'sdsdds')
    ]
  end

  it do
    puts Benchmark.measure {
      5_000.times { $out = data.hash }
    }
    puts $out
    puts data[2].asd
    puts data[2].asd = 'S'
    puts data.hash
  end
end

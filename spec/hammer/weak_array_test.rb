# encoding: UTF-8

# require `gem which memprof/signal`.chomp

module Hammer; end
require File.expand_path(File.dirname(__FILE__) + '/../../lib/hammer/weak_array.rb')

class Foo < Object; end

lambda do

  weak_array = lambda do
    elem = Foo.new
    weak_array = Hammer::WeakArray.new
    weak_array.push elem

    puts '-- should 1'
    weak_array.each {|e| p e }
    weak_array
  end.call

  puts '-- should 1'
  lambda { weak_array.each {|e| p e } }.call
  GC.start; GC.start; sleep 0.1
  puts '-- should 0'
  lambda { weak_array.each {|e| p e } }.call

end.call
GC.start; GC.start; sleep 0.1;
puts '----'


lambda do
  weak_id = lambda do
    weak_array = Hammer::WeakArray.new
    weak_array.object_id
  end.call

  lambda { puts '-- should a weak array', (ObjectSpace._id2ref(weak_id) rescue nil) }

  GC.start; GC.start; sleep 0.1

  puts '-- should nil', (ObjectSpace._id2ref(weak_id) rescue nil)

end.call
GC.start; GC.start; sleep 0.1
puts '----'


lambda do
  elem, weak_id = lambda do
    elem = Foo.new
    weak_array = Hammer::WeakArray.new
    weak_array.push elem

    puts '-- should 1'
    weak_array.each {|e| p e }

    [elem, weak_array.object_id]
  end.call

  lambda { puts '-- should a weak array', (ObjectSpace._id2ref(weak_id) rescue nil) }.call

  GC.start; GC.start; sleep 0.1

  puts '-- should nil', (ObjectSpace._id2ref(weak_id) rescue nil)

end.call
GC.start; GC.start; sleep 0.1
puts '----'

#Memprof.dump_all 'file.json'

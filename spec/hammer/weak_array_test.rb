# encoding: UTF-8

# require `gem which memprof/signal`.chomp

#module Hammer; end
#require File.expand_path(File.dirname(__FILE__) + '/../../lib/hammer/weak.rb')

require 'rubygems'
require 'hammer'

def trigger_gc
  ObjectSpace.define_finalizer(Object.new, proc {})
  GC.start
end

#class Foo < Object; end
#
#lambda do
#
#  weak_array = lambda do
#    elem = Foo.new
#    weak_array = Hammer::WeakArray.new
#    weak_array.push elem
#
#    puts '-- should 1'
#    weak_array.each {|e| p e }
#    weak_array
#  end.call
#
#  puts '-- should 1'
#  lambda { weak_array.each {|e| p e } }.call
#  trigger_gc
#  puts '-- should 0'
#  lambda { weak_array.each {|e| p e } }.call
#
#end.call
#trigger_gc;
#puts '----'
#
#
#lambda do
#  weak_id = lambda do
#    weak_array = Hammer::WeakArray.new
#    weak_array.object_id
#  end.call
#
#  lambda { puts '-- should a weak array', (ObjectSpace._id2ref(weak_id) rescue nil) }
#
#  trigger_gc
#
#  puts '-- should nil', (ObjectSpace._id2ref(weak_id) rescue nil)
#
#end.call
#trigger_gc
#puts '----'
#
#
#lambda do
#  elem, weak_id = lambda do
#    elem = Foo.new
#    weak_array = Hammer::WeakArray.new
#    weak_array.push elem
#
#    puts '-- should 1'
#    weak_array.each {|e| p e }
#
#    [elem, weak_array.object_id]
#  end.call
#
#  lambda { puts '-- should a weak array', (ObjectSpace._id2ref(weak_id) rescue nil) }.call
#
#  trigger_gc
#
#  puts '-- should nil', (ObjectSpace._id2ref(weak_id) rescue nil)
#
#end.call
#trigger_gc
#puts '----'

#Memprof.dump_all 'file.json'

q = Hammer::Weak::Queue.new.push(Object.new)

p q.to_a
p Hammer::Finalizer.get

trigger_gc

p q.to_a
p Hammer::Finalizer.get
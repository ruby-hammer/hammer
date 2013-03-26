require 'weakref'
require 'java' if defined? JRUBY_VERSION

# TODO add support for WeakSet http://jruby.org/apidocs/org/jruby/util/collections/WeakHashSet.html
# TODO add working alternative for MRI

module Hammer
  module Weak
    class Abstract

      private

      def weak_ref(object)
        ensure_collectable! object
        WeakRef.new object
      end

      def get(weak_ref)
        weak_ref.__getobj__
      rescue WeakRef::RefError
        nil
      end

      def ensure_collectable!(value)
        if [TrueClass, FalseClass, NilClass, Fixnum, Float, Symbol].any? { |klass| value.kind_of? klass }
          raise ArgumentError, "#{value.inspect} cannot be collected"
        end
      end
    end

    class Queue < Abstract
      def initialize
        @data = []
      end

      def push(*values)
        values.each { |v| @data.push weak_ref(v) }
      end

      def pop
        if (ref = @data.pop)
          ref.__getobj__
        else
          nil
        end
      rescue WeakRef::RefError
        retry
      end

      def each(&iterator)
        @data.delete_if do |weak_ref|
          if (object = get weak_ref)
            iterator.call object
            false # keep
          else
            true # delete
          end
        end

        self
      end
    end

    unless defined? JRUBY_VERSION
      class WeakKeyHash < Hash
        #def initialize
        #  @data = {}
        #  @keys = {}
        #end
        #
        #def [](key)
        #  stored_key = get(@keys[key.object_id])
        #  if stored_key == key
        #    @data[key.object_id]
        #  else
        #
        #    nil
        #  end
        #end
        #
        #def []=(key, value)
        #  @data[key.object_id] = value
        #  @keys[key.object_id] = weak_ref(key)
        #end
        #
        #def each(&block)
        #  @data.entrySet().iterator.each do |pair|
        #    key, value = pair.getKey, pair.getValue
        #    block.call [key, value]
        #  end
        #end
        #
        #include Enumerable
      end
    else
      class WeakKeyHash < Abstract
        def initialize
          @data = java.util.WeakHashMap.new
        end

        def [](key)
          @data.get key.to_java(org.jruby.RubyObject)
        end

        def []=(key, value)
          ensure_collectable! key
          @data.put key.to_java(org.jruby.RubyObject), value
        end

        def delete(key)
          @data.remove key.to_java(org.jruby.RubyObject)
        end

        def each(&block)
          @data.entrySet().iterator.each do |pair|
            key, value = pair.getKey, pair.getValue
            block.call [key, value]
          end
        end

        include Enumerable
      end

    end

    unless defined? JRUBY_VERSION
      class WeakHash < Hash
      end
    else
      class WeakHash < WeakKeyHash
        def [](key)
          get(super(key)).tap { |v| delete key unless v }
        end

        def []=(key, value)
          ensure_collectable! value
          super(key, weak_ref(value))
        end

        def delete(key)
          get super(key)
        end

        def each(&block)
          super do |k, ref|
            if (v = get ref)
              block.call [k, v]
            else
              delete k
            end
          end
        end
      end
    end
  end
end

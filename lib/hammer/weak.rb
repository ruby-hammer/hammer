require "hammer/finalizer.rb"

module Hammer::Weak

  # abstract class for weak collections
  class Abstract

    include Enumerable

    # adds collection's finalizer
    def initialize
      Hammer::Finalizer.add self, :"#{self.class}", self.class.finalize_itself
    end

    # @return [Fixnum] collection's size
    def size
      storage.size
    end

    # @return [Boolean] if collection is empty
    def empty?
      size == 0
    end

    private

    # @param [Fixnum, nil] object_id by which is object searched
    # @return [Object, nil] by its object_id
    def get_object(id)
      ObjectSpace._id2ref id if id
    rescue RangeError
    end

    # @return collection's storage
    def storage
      self.class.storage(self.object_id)
    end

    # @param [Fixnum] id collection's object_id
    # @return collection's storage by id
    def self.storage(id)
      @storages[id]
    end

    # @return [Hash{Fixnum=>Object}] all storages
    def self.storages
      @storages
    end

    @storages = {}
    # initializes @storages in subclasses
    def self.inherited(subclass)
      super
      subclass.instance_eval { @storages = {} }
    end

  end

  # Weak Queue
  class Queue < Abstract

    def initialize
      super
      self.class.storages[object_id] = []
    end

    # like Array#push
    def push(*objects)
      add(:push, *objects)
    end

    # like Array#delete but can delete multiple objects
    def delete(*objects)
      objects.each do |object|
        Hammer::Finalizer.remove(object, object_id).call(object.object_id)
      end
      objects
    end

    # like Array#pop
    def pop(n = 1)
      delete(*storage.last(n))
    end

    # like Array#shift
    def shift(n = 1)
      delete(*storage.first(n))
    end

    # like Array#unshift
    def unshift(*objects)
      add(:unshift, objects)
    end

    # iterates through queue
    def each(&block)
      storage.each do |id|
        if obj = get_object(id)
          block.call obj
        end
      end
    end

    # @return [Array<Object>] with all objects stored in Queue
    def to_a
      storage.map {|id| get_object(id)}.compact
    end

    private

    def add(method, *objects)
      objects.each do |object|
        storage.send(method, object.object_id)
        Hammer::Finalizer.add object, object_id, self.class.finalize_item(object_id)
      end
      self
    end

    def self.finalize_item(queue_id)
      lambda {|id| storage(queue_id).delete(id) }
    end

    def self.finalize_itself
      lambda do |queue_id|
        storage(queue_id).each {|item_id| Hammer::Finalizer.remove(item_id, queue_id) }
        storages.delete queue_id
      end
    end

  end

  # Hash like structure which effectively handles operations in both directions from keys and values
  class BidirectionalHash
    def initialize
      @hash, @reverse = {}, {}
    end

    # adds pair +key+, +value+
    # @param [Object] key
    # @param [Object] value
    def add(key, value)
      @hash[key] = value
      @reverse[value] ||= []
      @reverse[value] << key
    end

    # @param [Object] key
    # @return [Object] value for +kye+
    def get(key)
      @hash[key]
    end

    # @param [Object] value
    # @return [Array<object>] array of keys for +value+
    def get_keys(value)
      @reverse[value] || []
    end

    # deletes pair on +key+
    # @param [Object] key
    def delete(key)
      if value = @hash[key]
        @reverse[value].delete(key)
        @reverse.delete value if @reverse[value].empty?
        @hash.delete key
      end
    end

    # deletes pairs with +value+
    # @param [Object] value
    def delete_value(value)
      keys = @reverse[value]
      @reverse.delete value
      keys.each {|key| @hash.delete(key) }
    end

    def each(&block)
      @hash.each {|k,v| block.call k,v }
    end

    def size
      @hash.size
    end
  end

  class AbstractHash < Abstract
    # like Hash
    def []=(key, value)
      delete(key)
      add(key, value)
      value
    end

    # @return [Hash]
    def to_hash
      inject({}) do |hash, pair|
        k,v = pair
        hash[k] = v
        hash
      end
    end

    # like Hash
    def keys
      to_hash.keys
    end

    # like Hash
    def values
      to_hash.values
    end
  end

  # Hash with weakly held values
  class WeakValueHash < AbstractHash
    def initialize
      super
      self.class.storages[object_id] = BidirectionalHash.new
    end

    # like Hash
    def each(&block)
      storage.each do |k,v|
        if value = get_object(v)
          block.call k, value
        end
      end
    end

    # like Hash
    def [](key)
      get_object storage.get(key)
    end

    # like Hash
    def has_key?(key)
      !!get_object(storage.get(key))
    end

    # like Hash
    def delete(key)
      value = storage.get key
      storage.delete key
      Hammer::Finalizer.remove value, object_id if storage.get_keys(value).blank?
      value
    end

    private

    # used by #[]=
    def add(key, value)
      storage.add key, value.object_id
      unless Hammer::Finalizer.get value, object_id
        Hammer::Finalizer.add value, object_id, self.class.finalize_item(object_id)
      end
    end

    def self.finalize_item(hash_id)
      lambda {|id| storage(hash_id).delete_value(id) }
    end

    def self.finalize_itself
      lambda do |hash_id|
        storage(hash_id).each {|_,value_id| Hammer::Finalizer.remove(value_id, hash_id) }
        storages.delete hash_id
      end
    end
  end

  # Hash like structure separating hash values from keys
  class ByHashHash
    def initialize
      @hash, @key_hash = {}, BidirectionalHash.new
    end

    # adds +key+ with its +hash+ and +value+
    def add(key, hash, value)
      @hash[key] = value
      @key_hash.add(key, hash)
    end

    # @return value
    def get(key)
      @hash[key]
    end

    # @return [Array<Array<>>] array of pair candidates
    # multiple objects can have same hash
    def get_candidates(hash)
      return @key_hash.get_keys(hash).map {|key| [key, @hash[key]] }
    end

    # deletes pair by +key+
    def delete(key)
      @hash.delete key
      @key_hash.delete key
    end

    # iterates through key,value pairs
    def each(&block)
      @hash.each {|k,v| block.call k,v }
    end

    def size
      @hash.size
    end
  end

  # Hash with weakly held keys
  class WeakKeyHash < AbstractHash
    def initialize
      super
      self.class.storages[object_id] = ByHashHash.new
    end

    # like Hash
    def [](key)
      get_key_value(key).try :last
    end

    # like Hash
    def has_key?(key)
      !!get_key_value(key)
    end

    # like Hash
    def delete(key)
      key_id, value = get_key_value(key)
      Hammer::Finalizer.remove(key_id, object_id).call(key_id) if key_id
      value
    end

    # like Hash
    def each(&block)
      storage.each do |k,v|
        if key = get_object(k)
          block.call key, v
        end
      end
    end

    private

    # find a right pair from candidates with same hash
    # @return array of id and value or nil
    def get_key_value(key)
      if v = storage.get(key.object_id)
        return key.object_id, v
      end
      storage.get_candidates(key.hash).find do |k,v|
        candidate_key = get_object(k) or next
        candidate_key.eql? key
      end
    end

    def add(key, value)
      storage.add key.object_id, key.hash, value
      Hammer::Finalizer.add key, object_id, self.class.finalize_item(object_id)
    end

    def self.finalize_item(hash_id)
      lambda {|id| storage(hash_id).delete(id) }
    end

    def self.finalize_itself
      lambda do |hash_id|
        storage(hash_id).each {|key_id, _| Hammer::Finalizer.remove(key_id, hash_id) }
        storages.delete hash_id
      end
    end
  end

  # shortcut to find proper hash
  # @example
  #  Hammer::Weak::Hash[:value] # => WeakValueHash
  #  Hammer::Weak::Hash[:key]   # => WeakKeyHash
  Hash = {
    :value => WeakValueHash,
    :key => WeakKeyHash
  }


  #  module ReferenceFinder
  #    class << self
  #      def find(scope, id)
  #        GC.disable
  #
  #        puts "object_space: #{ObjectSpace.each_object {}}"
  #
  #        arr = [
  #          Hammer
  ##          scope,
  ##          Object,
  ##          *(global_variables - [:$=]).map {|gv| eval(gv.to_s) }
  #        ]
  #
  #        references = {}
  #
  #        inspections = [
  #          { :type => :instance_variable,
  #            :condition => lambda {|i| i.respond_to? :instance_variables },
  #            :names => lambda {|i| i.instance_variables },
  #            :retrieve => lambda {|i, name| i.instance_variable_get(name) }
  #          },
  #          { :type => :class_variable,
  #            :condition => lambda {|i| i.respond_to? :class_variables },
  #            :names => lambda {|i| i.class_variables },
  #            :retrieve => lambda {|i, name| i.class_variable_get(name) }
  #          },
  #          { :type => :constant,
  #            :condition => lambda {|i| i.respond_to? :constants },
  #            :names => lambda {|i| i.constants },
  #            :retrieve => lambda {|i, name| i.const_get(name) }
  #          },
  #          { :type => :local_variable,
  #            :condition => lambda {|i| i.respond_to? :local_variables },
  #            :names => lambda {|i| i.local_variables },
  #            :retrieve => lambda {|i, name| i.eval(name.to_s) }
  #          },
  #          { :type => :scope,
  #            :condition => lambda {|i| i.kind_of? Proc },
  #            :names => lambda {|i| [:scope] },
  #            :retrieve => lambda {|i, name| i.scope }
  #          },
  #          { :type => :array,
  #            :condition => lambda {|i| i.kind_of? Array },
  #            :names => lambda {|i| Array.new(i.size) {|n| n } },
  #            :retrieve => lambda {|i, name| i[name] }
  #          },
  #          { :type => :hash_key,
  #            :condition => lambda {|i| i.kind_of? Hash },
  #            :names => lambda {|i| Array.new(i.size) {|n| n } },
  #            :retrieve => lambda {|i, name| i.keys[name] }
  #          },
  #          { :type => :hash_value,
  #            :condition => lambda {|i| i.kind_of? Hash },
  #            :names => lambda {|i| i.keys },
  #            :retrieve => lambda {|i, name| i[name] }
  #          }
  #        ]
  #
  #        while inspecte = arr.shift
  ##          p '----', inspecte
  #          inspections.each do |inspection|
  #            begin
  #            if inspection[:condition].call(inspecte)
  ##              p inspection[:type]
  ##              p inspection[:names].call(inspecte)
  #              inspection[:names].call(inspecte).each do |name|
  #                obj = inspection[:retrieve].call(inspecte, name)
  #                references[obj.object_id] ||= []
  #                references[obj.object_id] << {:type => inspection[:type], :name => name, :obj => inspecte.object_id }
  #                arr.push obj
  #              end
  #            end
  #            rescue Exception => e
  #              p inspecte, e
  #              puts e.backtrace.join("\n")
  #            end
  #          end
  #        end
  #
  #        puts "finded objects #{references.size}"
  ##        pp references
  #        pp references[id]
  #
  #        GC.enable
  #      end
  #    end
  #  end
end

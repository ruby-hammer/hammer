module Hammer::Weak

  # holds objects weakly
  #  class WeakArray
  #
  #    class ReferenceStore
  #      def initialize
  #        @reference_array_by_weakhash_id = {}
  #        @reference_arrays_by_obj_id = {}
  #      end
  #
  #      def add(weak_array_id, obj_id)
  #        ref_arr = reference_array(weak_array_id) << obj_id
  #        ref_arrs = reference_arrays(obj_id)
  #        ref_arrs << ref_arr unless ref_arrs.include? ref_arr
  #      end
  #
  #      def remove_weak_array(weak_array_id)
  #        (ref_arr = @reference_array_by_weakhash_id.delete(weak_array_id)).each do |ref|
  #          remove_referenece_array(ref, ref_arr)
  #        end
  #      end
  #
  #      def remove_object_id(obj_id)
  #        reference_arrays(obj_id).each {|arr| arr.delete obj_id }
  #        @reference_arrays_by_obj_id.delete obj_id
  #      end
  #
  #      def remove(weak_array_id, obj_id)
  #        (ref_arr = reference_array(weak_array_id)).delete(obj_id)
  #        remove_referenece_array(obj_id, ref_arr)
  #      end
  #
  #      # @param [Fixnum] weak_array_id
  #      # @return [Array<Fixnum>] of references for +weak_array_id+
  #      def reference_array(weak_array_id)
  #        @reference_array_by_weakhash_id[weak_array_id] ||= ReferenceArray.new
  #      end
  #
  #      # @param [Fixnum] obj_id
  #      # @return [Set] of reference arrays containing +object_id+
  #      def reference_arrays(obj_id)
  #        @reference_arrays_by_obj_id[obj_id] ||= []
  #      end
  #
  #      private
  #
  #      def remove_referenece_array(obj_id, reference_array)
  #        (ref_arrs = reference_arrays(obj_id)).delete reference_array
  #        @reference_arrays_by_obj_id.delete obj_id if ref_arrs.empty?
  #      end
  #    end
  #
  #    class ReferenceArray < Array
  #      def ==(other)
  #        object_id == other.object_id
  #      end
  #    end
  #
  #    STORE = ReferenceStore.new unless defined? STORE
  #
  #    include Enumerable
  #
  #    # @param [Object] objects which will be inserted into array
  #    def initialize(*objects)
  #      # drop reference array after this instance of WeakArray is GCed
  #      ObjectSpace.define_finalizer(self, self.class.finalizer_for_reference_array)
  #      push *objects
  #    end
  #
  #    # @param [Object] objects which will be inserted into array
  #    # @return self
  #    def push(*objects)
  #      objects.each do |obj|
  #        # delete its id after obj is GCed
  #        unless obj.instance_variable_get :@__weak_array_finalizer
  #          ObjectSpace.define_finalizer(obj, self.class.finalizer_for_weakly_held_object)
  #          obj.instance_variable_set :@__weak_array_finalizer, true
  #        end
  #        STORE.add(object_id, obj.object_id)
  #      end
  #      self
  #    end
  #
  #    alias_method :<<, :push
  #
  #    # @yield block iterated through array
  #    # @yieldparam [Object] object in current iteration
  #    # @return self
  #    def each(&block)
  #      STORE.reference_array(object_id).each do |id|
  #        if obj = get_object(id)
  #          block.call obj
  #        end
  #      end
  #      self
  #    end
  #
  #    # @param [Object] obj to delete
  #    # @return [Object, nil] deleted object or nil when +obj+ was not found
  #    def delete(obj)
  #      STORE.remove_object_id(obj.object_id)
  #    end
  #
  #    # @return [Array<Objects>] of stored objects
  #    def to_a
  #      self.inject([]) {|arr, obj| arr << obj }
  #    end
  #
  #    private
  #
  #    # @return [Object, nil] retrieved object or nil
  #    def get_object(id)
  #      ObjectSpace._id2ref id
  #    rescue RangeError
  #    end
  #
  #    # @return [Proc] finalizer which delete references from array
  #    def self.finalizer_for_weakly_held_object
  #      proc {|object_id| STORE.remove_object_id(object_id) }
  #    end
  #
  #    # @return [Proc] finalizer which deletes reference array
  #    def self.finalizer_for_reference_array
  #      proc {|object_id| STORE.remove_weak_array(object_id) }
  #    end
  #
  #  end

  class Abstract
    def get_object(id)
      ObjectSpace._id2ref id
    rescue RangeError
    end
  end

  class Queue < Abstract

    def initialize
      Hammer::Finalizer.add self, :queue_finalizer, self.class.finalize_queue
    end

    def push(*objects)
      add(:push, *objects)
    end

    def delete(*objects)
      object_ids = objects.map(&:object_id)
      ids.delete_if {|id| object_ids.include? id }
      objects.each do |object|
        Hammer::Finalizer.remove(object, object_id)
      end
      objects
    end

    def pop(n = 1)
      delete(*ids.last(n))
    end

    def shift(n = 1)
      delete(*ids.first(n))
    end

    def unshift(*objects)
      add(:unshift, objects)
    end

    def each(&block)
      ids.each do |id|
        if obj = get_object(id)
          block.call obj
        end
      end
    end

    def size
      ids.size
    end

    def empty?
      size == 0
    end

    def to_a
      ids.map {|id| get_object(id)}.compact
    end

    include Enumerable

    private

    def add(method, *objects)
      objects.each do |object|
        ids.send(method, object.object_id)
        Hammer::Finalizer.add object, object_id, self.class.finalize_item(self.object_id)
      end
      self
    end

    def ids
      self.class.ids(self.object_id)
    end

    def self.finalize_item(queue_id)
      lambda {|id| self.ids(queue_id).delete(id) }
    end

    def self.finalize_queue
      lambda {|queue_id| self.ids(queue_id).each {|item_id| Hammer::Finalizer.remove(item_id, queue_id) }}
    end

    def self.ids(queue_id)
      @ids[queue_id] ||= []
    end

    @ids = {}
    def self.inherited(subclass)
      super
      subclass.instance_eval { @ids = {} }
    end
  end

  #  module ReferenceFinder
  #    class << self
  #      def find(scope, id)
  #        GC.disable
  #
  #        puts "object_space: #{ObjectSpace.each_object {}}"
  #
  #        arr = [
  #          scope,
  #          Object,
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
  #            :retrieve => lambda {|i, name| eval('self', i.binding) }
  #          }
  #        ]
  #
  #        while inspecte = arr.shift
  #          p '----', inspecte
  #          inspections.each do |inspection|
  #            begin
  #            if inspection[:condition].call(inspecte)
  #              p inspection[:type]
  #              p inspection[:names].call(inspecte)
  #              inspection[:names].call(inspecte).each do |name|
  #                p obj = inspection[:retrieve].call(inspecte, name)
  #                references[obj.object_id] ||= []
  #                references[obj.object_id] << {:type => inspection[:type], :name => name, :obj => inspecte.object_id }
  #                arr.push obj
  #              end
  #            end
  #            rescue Exception => e
  #              p e, inspecte
  #              puts e.backtrace[0..5].join("\n")
  #            end
  #          end
  #        end
  #
  #        puts "finded objects #{references.size}"
  #        pp references[id]
  #
  #        GC.enable
  #      end
  #    end
  #  end
end

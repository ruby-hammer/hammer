# holds objects weakly
class Hammer::WeakArray

  class ReferenceStore
    def initialize
      @reference_array_by_weakhash_id = {}
      @reference_arrays_by_obj_id = {}
    end

    def add(weak_array_id, obj_id)
      ref_arr = reference_array(weak_array_id) << obj_id
      ref_arrs = reference_arrays(obj_id)
      ref_arrs << ref_arr unless ref_arrs.include? ref_arr
    end

    def remove_weak_array(weak_array_id)
      (ref_arr = @reference_array_by_weakhash_id.delete(weak_array_id)).each do |ref|
        remove_referenece_array(ref, ref_arr)
      end
    end

    def remove_object_id(obj_id)
      reference_arrays(obj_id).each {|arr| arr.delete obj_id }
      @reference_arrays_by_obj_id.delete obj_id
    end

    def remove(weak_array_id, obj_id)
      (ref_arr = reference_array(weak_array_id)).delete(obj_id)
      remove_referenece_array(obj_id, ref_arr)
    end

    # @param [Fixnum] weak_array_id
    # @return [Array<Fixnum>] of references for +weak_array_id+
    def reference_array(weak_array_id)
      @reference_array_by_weakhash_id[weak_array_id] ||= ReferenceArray.new
    end

    # @param [Fixnum] obj_id
    # @return [Set] of reference arrays containing +object_id+
    def reference_arrays(obj_id)
      @reference_arrays_by_obj_id[obj_id] ||= []
    end

    private

    def remove_referenece_array(obj_id, reference_array)
      (ref_arrs = reference_arrays(obj_id)).delete reference_array
      @reference_arrays_by_obj_id.delete obj_id if ref_arrs.empty?
    end
  end

  class ReferenceArray < Array
    def ==(other)
      object_id == other.object_id
    end
  end

  STORE = ReferenceStore.new unless defined? STORE

  include Enumerable

  # @param [Object] objects which will be inserted into array
  def initialize(*objects)
    # drop reference array after this instance of WeakArray is GCed
    ObjectSpace.define_finalizer(self, self.class.finalizer_for_reference_array)
    push *objects
  end

  # @param [Object] objects which will be inserted into array
  # @return self
  def push(*objects)
    objects.each do |obj|
      # delete its id after obj is GCed
      unless obj.instance_variable_get :@__weak_array_finalizer
        ObjectSpace.define_finalizer(obj, self.class.finalizer_for_weakly_held_object)
        obj.instance_variable_set :@__weak_array_finalizer, true
      end
      STORE.add(object_id, obj.object_id)
    end
    self
  end

  alias_method :<<, :push

  # @yield block iterated through array
  # @yieldparam [Object] object in current iteration
  # @return self
  def each(&block)
    STORE.reference_array(object_id).each do |id|
      if obj = get_object(id)
        block.call obj
      end
    end
    self
  end

  # @param [Object] obj to delete
  # @return [Object, nil] deleted object or nil when +obj+ was not found
  def delete(obj)
    STORE.remove_object_id(obj.object_id)
  end

  # @return [Array<Objects>] of stored objects
  def to_a
    self.inject([]) {|arr, obj| arr << obj }
  end

  private

  # @return [Object, nil] retrieved object or nil
  def get_object(id)
    ObjectSpace._id2ref id
  rescue RangeError
  end

  # @return [Proc] finalizer which delete references from array
  def self.finalizer_for_weakly_held_object
    proc {|object_id| STORE.remove_object_id(object_id) }
  end

  # @return [Proc] finalizer which deletes reference array
  def self.finalizer_for_reference_array
    proc {|object_id| STORE.remove_weak_array(object_id) }
  end

end

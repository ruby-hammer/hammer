MAIN_SCOPE = self

# finalizer abstraction
module Hammer::Finalizer
  class << self

    # adds +finalizer+ to a +obj+ under +name+
    # @param [Object, Fixnum] obj where will be +finalizer+ attached
    # @param [Object] name key for later identification. Be careful what you use as key, keys will not be GCed.
    # @param [Proc] finalizer
    def add(obj, name, finalizer)
      obj, id = get_obj(obj), get_id(obj)
      check_block(obj, finalizer)
      install_finalizer(obj)
      @finalizers ||= {}
      @finalizers[id] ||= {}
      @finalizers[id][name] = finalizer
      nil
    end

    # returns attached finalizers
    # @param [Array<Object>] options if passed obj returns obj's finalizers. if passed returns finalizer with that name
    # @return [Hash{Fixnum=>Hash{Object=>Proc}},Hash{Object=>Proc},Proc] based on which arguments are passed
    # @example
    #   get(a_obj, :key) # => Proc
    #   get(a_obj) # => {:key => Proc}
    #   get # => {8212000 => {:key => Proc}
    def get(*options)
      case options.size
      when 0 then
        @finalizers
      when 1 then
        id = get_id options[0]
        @finalizers[id]
      when 2 then
        id = get_id options[0]
        @finalizers[id][options[1]]
      end
    end

    # removes finalizer attached to +obj+ under +name+
    # @param [Object, Fixnum] obj where is finalizer attached
    # @param [Object] name under which is finalizer +attached+
    def remove(obj, name)
      id = get_id(obj)
      if @finalizers[id]
        @finalizers[id].delete name if @finalizers[id][name]
        @finalizers.delete id if @finalizers[id].empty?
      end
      nil
    end

    private

    def get_id(obj)
      if obj.kind_of?(Fixnum)
        obj
      else
        obj.object_id
      end
    end

    def get_obj(obj)
      if obj.kind_of?(Fixnum)
        ObjectSpace._id2ref(obj) rescue nil
      else
        obj
      end
    end

    # raises RuntimeError if finalizer blocks any instances
    def check_block(obj, finalizer)
      bind = eval('self', finalizer.binding)
      raise 'finalizer blocks its own instance' if obj == bind
      raise "finalizer blocks instance #{bind.inspect}\n" unless bind.kind_of?(Module) || bind == MAIN_SCOPE
    end

    # install finalizer hook only once
    def install_finalizer(obj)
      unless obj.instance_variable_get :@__finalizer_instaled
        obj.instance_variable_set :@__finalizer_instaled, true
        ObjectSpace.define_finalizer(obj, finalizer)
      end
    end

    # executes finalizers
    def finalizer
      lambda do |object_id|
        #        puts "finalizing #{object_id}"
        @finalizers[object_id].each do |_,finalizer|
          begin
            finalizer.call(object_id)
          rescue Exception => e
            puts "#{e.inspect}\n#{e.backtrace.join("\n")}"
          end
        end
        @finalizers.delete object_id
      end
    end
  end
end


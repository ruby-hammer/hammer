MAIN_SCOPE = self

# finalizer abstraction
module Hammer::Finalizer
  class << self

    # adds +finalizer+ to a +obj+ under +name+
    # @param [Object] obj where will be +finalizer+ attached
    # @param [Object] name key for later identification. Be careful what you use as key, keys will not be GCed.
    # @param [Proc] finalizer
    def add(obj, name, finalizer)
      check_block(obj, finalizer)
      install_finalizer(obj)
      @finalizers ||= {}
      @finalizers[obj.object_id] ||= {}
      @finalizers[obj.object_id][name] = finalizer
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
      when 0 then @finalizers
      when 1 then @finalizers[options[0].object_id]
      when 2 then @finalizers[options[0].object_id][options[1]]
      end
    end

    # removes finalizer attached to +obj+ under +name+
    # @param [Object] obj where is finalizer attached
    # @param [Object] name under which is finalizer +attached+
    def remove(obj, name)
      if @finalizers[obj.object_id]
        @finalizers[obj.object_id].delete name if @finalizers[obj.object_id][name]
        @finalizers.delete obj.object_id if @finalizers[obj.object_id].empty?
      end
      nil
    end

    private

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

#def gc
#  ObjectSpace.define_finalizer(Object.new, proc {})
#  ObjectSpace.garbage_collect
#end
#
#Finalizer.add Object.new, :t, proc {|id| p id }
#p Finalizer.get
#gc
#p 'end'
#
#
#class A
#  @@finalizer = proc { p 2 }
#
#  def initialize
#    Finalizer.add self, nil, @@finalizer
#  end
#end
#
#A.new
#p Finalizer.get
#gc
#p 'end'
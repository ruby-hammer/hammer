module Hammer::Component::State

  def self.included(base)
    base.extend ClassMethods
    base.instance_eval do
      def method_added(name)
        super
        @_new_changing_methods ||= []
        @_new_changing_methods << name
      end
    end
    base.class_inheritable_array :changing_methods
    base.after_initialize { change! }
  end

  module ClassMethods
    # signs instance methods that they are changing component's state
    # @param [Array<Symbol>] names of changing methods
    # @yield block signs methods defined within the block
    # @example methods :b and :c are changing state
    #   class AComponent < Hammer::Component::Base
    #     def a; end
    #     def b; end
    #     changing do
    #       def c; end
    #     end
    #     changing :b
    #   end
    def changing(*names, &block)
      case
      when names.present? then
        names.each {|name| hook_change_to_method(name) }
        self.changing_methods = names
      when block
        @_new_changing_methods = []
        block.call
        changing *@_new_changing_methods
      else raise ArgumentError
      end
    end

    private

    # hooks {#change!} after method with +name+
    def hook_change_to_method(name)
      name.to_s =~ /^([\w_]*)(|\?|!|=)$/
      class_eval <<-STR , __FILE__, __LINE__+1
        def #{$1}_with_change#{$2}(*args, &block)
          __send__ "#{$1}_without_change#{$2}", *args, &block
          change!
        end
      STR
      alias_method_chain(name, :change)
    end
  end

  # tells component that it's changed
  def change!
    @_changed = true
    @_sended = false
    self
  end

  # @return [Boolean] if component id changed
  def changed?
    !!@_changed
  end

  # resets component change state
  def reset_change!
    @_changed = false
    self
  end

  # is updated html sended to client?
  def unsended?
    !@_sended
  end

  # set to update to sended
  def send!
    @_sended = true
    self
  end
end

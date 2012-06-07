module Hammer::Component::StateHelper

  def self.extended(base)
    base.instance_eval do
      def method_added(name)
        super
        @_new_changing_methods ||= []
        @_new_changing_methods << name
      end
    end
    base.class_attribute :changing_methods, :instance_writer => false, :instance_reader => false
    base.changing_methods ||= []
  end

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
        names.each { |name| hook_change_to_method(name) }
        self.changing_methods += names
      when block
        @_new_changing_methods = []
        block.call
        changing *@_new_changing_methods
      else
        raise ArgumentError
    end
  end

  private

  # hooks {#change!} after method with +name+
  def hook_change_to_method(name)
    name.to_s =~ /^([\w_]*)(|\?|!|=)$/
    class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{$1}_with_change#{$2}(*args, &block)
          state.change!
          __send__ "#{$1}_without_change#{$2}", *args, &block
        end
    RUBY
    alias_method_chain(name, :change)
  end
end

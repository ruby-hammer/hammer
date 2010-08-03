# encoding: UTF-8

module Hammer::Component

  class SuperAbstract
    include Erector::Needs
    include Erector::AfterInitialize
  end

  # represents component of a page. The basic logic building blocks of a application.
  class Abstract < SuperAbstract

    needs :context
    attr_reader :context

    def initialize(assigns = {})
      check_assigns(assigns)
      @_assigns = assigns

      assigns.each do |name, value|
        instance_variable_set(name.to_s[0] == '@' ? name : "@#{name}", value)
      end

      super
    end

    # adds proper {Core::Context} automatically
    # @param [Hash] assigns are passed to +klass+.new
    def self.new(assigns = {})
      assigns[:context] ||= get_context
      super assigns
    end

    # registers action to #component for later evaluation
    # @yield action block to register
    # @return [String] uuid of the action
    def register_action(&block)
      context.register_action(self, &block)
    end

    private

    def check_assigns(assigns)
      unless assigns.kind_of? Hash
        raise "assigns is not a Hash: #{assigns.inspect}"
      end
    end

    def self.get_context
      raise('trying to create outside Fiber') unless Fiber.current.respond_to? :hammer_context
      Fiber.current.hammer_context || raise('unset context in fiber')
    end

  end
end

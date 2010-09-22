# encoding: UTF-8

module Hammer::Component

  module AbstractImpl
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # adds proper {Core::Context} automatically
      # @param [Hash] assigns are passed to +klass+.new
      def new(assigns = {})
        assigns[:context] ||= Hammer.get_context || raise('trying to create outside Fiber')
        super assigns
      end
    end

    # stores assigns into instance_variables
    def initialize(assigns = {})
      check_assigns(assigns)
      @_assigns = assigns
      @actions = {}

      assigns.each do |name, value|
        instance_variable_set(name.to_s[0] == '@' ? name : "@#{name}", value)
      end
    end

    # creates and stores action for later evaluation
    # @param [Component::Base] component where action will be evaluated
    # @yield the action
    # @return [String] uuid of the action
    def register_action(&block)
      uuid = Hammer::Core.generate_id
      @actions[uuid] = Hammer::Core::Action.new(uuid, self, block)
      context.register_action(uuid, self)
      return uuid
    end

    # evaluates action with +id+, do nothing when no action
    # @param [String] id of a {Hammer::Core::Action}
    # @param [String] arg if of a {Hammer::Component::Base}
    # @return self
    def run_action(id, arg)
      return self unless action = @actions[id]
      action.call(Hammer::Core.component_by_id(arg))
      self
    end

    # is component root of the context
    def root?
      context.root_component == self
    end

    private

    def check_assigns(assigns)
      unless assigns.kind_of? Hash
        raise "assigns is not a Hash: #{assigns.inspect}"
      end
    end

  end

  # represents component of a page. The basic logic building blocks of a application.
  class Abstract
    include AbstractImpl
    include Erector::Needs
    include Erector::AfterInitialize

    needs :context
    attr_reader :context
  end
end

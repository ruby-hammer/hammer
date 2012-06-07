module Hammer
  class Component::Actions
    attr_reader :component

    def initialize(component)
      @actions   = { }
      @component = component
    end

    # creates and stores action for later evaluation
    # @param [Component::Base] component where action will be evaluated
    # @yield the action
    # @return [String] id of the action
    def register(&block)
      id           = component.core.generate.id
      @actions[id] = Core::Action.new(id, component, block)
      component.app.action_dispatcher.register(id, component)
      return id
    end

    # evaluates action with +id+, do nothing when no action
    # @param [String] id of a {Hammer::Core::Action}
    # @param [String] arg if of a {Hammer::Component::Base}
    # @return self
    def run(id, *args)
      unless action = @actions[id]
        component.app.logger.warn "no action with id #{action.id} in component #{component.id}"
      else
        action.call(*args)
      end
      self
    end

    def clear
      @actions.clear
    end

    def to_hash
      @actions
    end

  end
end

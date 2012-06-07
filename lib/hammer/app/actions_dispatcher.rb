class Hammer::App::ActionsDispatcher

  attr_reader :app

  def initialize(app)
    @app     = app
    @actions = Hammer::Weak::Hash[:value].new
  end

  # registers action in context's hash
  # @param [Component::Base] component where action is stored and evaluated
  # @param [String] uuid of the action
  # @return self
  def register(uuid, component)
    @actions[uuid] = component
    self
  end

  # evaluates action with +id+, do nothing when no action
  # @param [String] action_id of a {Action}
  # @param [String] arg if of a {Hammer::Component::Base}
  # @return self
  def run(action_id, *args)
    component = @actions[action_id]

    unless component
      app.logger.warn "no component for action with id #{action_id.inspect}"
    else
      component.actions.run(action_id, *args)
    end
  end

  def to_hash
    @actions.to_hash
  end
end

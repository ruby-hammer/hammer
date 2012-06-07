# represents action which are stored when link is added and evaluated on link click
class Hammer::Core::Action
  attr_reader :id, :component, :block

  # @param [String] id unique identification
  # @param [Component::Base] component
  # @param [Proc] block which is evaluated on link click
  def initialize(id, component, block)
    raise ArgumentError unless id && component && block
    @id, @component, @block = id, component, block
  end

  # executes action
  # @param [Hammer::Component::base] arg
  def call(*args)
    Hammer::Utils.benchmark component.app.logger, :info, "Running action #{block}" do
      component.send(:instance_exec, *args, &block)
    end
  end
end

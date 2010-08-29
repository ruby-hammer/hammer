# encoding: UTF-8

module Hammer::Core

  # represents action which are stored when link is added and evaluated on link click
  class Action
    attr_reader :id, :component, :block

    # @param [String] uuid unique identification
    # @param [Component::Base] component
    # @param [Proc] block which is evaluated on link click
    def initialize(uuid, component, block)
      raise ArgumentError unless uuid && component && block
      @uuid, @component, @block = uuid, component, block
    end

    # executes action
    # @param [Hammer::Component::base] arg
    def call(arg)
      Hammer.benchmark "Running action #{block}" do
        component.send(:instance_exec, arg, &block)
      end
    end
  end
end

module Hammer::Apps
  class Abstract
    require "hammer/apps/actions_dispatcher.rb"
    require "hammer/apps/scheduler.rb"

    attr_reader :context, :schedule, :id, :app_component, :action_dispatcher, :logger

    def wrapper(builder)
      builder.render app_component, :wrapper
    end

    def initialize(context, id, options = {})
      @context           = context
      @schedule          = options[:scheduler] || Scheduler.new(self)
      @id                = id
      @action_dispatcher = options[:action_dispatcher] || ActionsDispatcher.new(self)
      @logger            = core.logging[id]
      @app_component     = create_app_component
    end

    def create_app_component
      raise NotImplementedError
    end

    def core
      context.core
    end

    def receive_message(message)
      unless message.app_id == id
        raise ArgumentError, 'wrong app_id'
      end

      case message.type
      when 'initContent'
        schedule.update
      when 'action'
        schedule.action do
          action_dispatcher.run message.action_id, *(message.args || [])
        end
      when 'value'
        raise NotImplementedError
      else
        logger.warn "wrong message: #{message.pretty_inspect.chop!}"
      end
    end

    def send_message(message)
      message.app_id ||= id
      context.send_message(message)
    end

    def send_updates(message = Hammer::Message.new_from_hash)
      message.updates = updates
      message.type    = 'update'
      send_message message
    end

    # collect updates for user
    def updates
      updates = []
      Hammer::Utils.benchmark(logger, :info, 'Rendering') do
        app_component.updater.all_unsent_components.each do |component|
          updates << [component.id, component.updater.update]
          component.state.send!
        end
      end

      return updates
    end
  end
end

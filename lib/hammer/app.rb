module Hammer
  class App
    # FIND maybe move under core
    require "hammer/app/actions_dispatcher.rb"
    require "hammer/app/scheduler.rb"

    attr_reader :context, :schedule, :id, :app_component, :action_dispatcher, :logger

    def wrapper(builder)
      builder.render app_component, :wrapper
    end

    def initialize(context, id, url, options = { }, &starter)
      @context           = context
      @schedule          = options[:scheduler] || Scheduler.new(self)
      @id                = id
      @starter           = starter
      @action_dispatcher = options[:action_dispatcher] || ActionsDispatcher.new(self)
      @logger            = core.logging[id]
      from_url url
    end

    def core
      context.core
    end

    def restart

    end

    def to_url
      app_component.to_url
    end

    def from_url(url)
      @app_component = @starter.call(self, url)
    end

    def receive_message(message)
      case message.type
        when 'initContent'
          schedule.action do
            message.updates = updates
            message.type    = 'update'
            send_message message
          end
        when 'action'
          schedule.action do
            action_dispatcher.run message.action_id, *(message.args || [])
            message.updates = updates
            message.type    = 'update'
            send_message message
          end
        when 'value'
          raise NotImplementedError
        else
          logger.warn "wrong message: #{message.pretty_inspect.chop!}"
      end
    end

    def send_message(message)
      context.send_message(message)
    end

    # collect updates for the user
    def updates
      updates = []
      Utils.benchmark(logger, :info, 'Rendering') do
        app_component.updater.all_unsent_components.each do |component|
          updates << [component.id, component.updater.update]
          component.state.send!
        end
      end

      return updates
    end
  end
end
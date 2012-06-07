module Hammer
  class Core
    require 'hammer/core/context'
    require 'hammer/core/fiber_pool'
    require 'hammer/core/action'
    require 'hammer/core/container'
    require 'hammer/core/id_generator'
    require 'hammer/core/logging'
    require 'hammer/core/adapters'
    require 'hammer/core/html_client'

    attr_reader :containers, :fiber_pool, :config, :generate, :logger,
                :hammer_builder_pool, :logging, :html_client, :adapter

    def initialize(config, options = { })
      @config              = config
      @containers          = { }
      @generate            = options[:id_generator] || IdGenerator.new
      @fiber_pool          = options[:fiber_pool] || FiberPool.new(config.core.fibers)
      @hammer_builder_pool = options[:builder_pool] || HammerBuilder::Pool.new(Hammer::Builder)
      @logging             = options[:logging] || Logging.new(self)
      @logger              = logging['core']
      #@node                = options[:node] || Node.new(self)
      @adapter             = options[:adapter] || Adapters::NodeZMQ.new(self)

      @html_client         = hammer_builder_pool.get.render(HtmlClient.new(self), :content).to_html!
    end

    # @return [Container] container by user_id (session id is used)
    def container(session_id)
      containers[session_id] ||= Container.new(session_id, self)
    end

    def current_app
      fiber_pool.current_app
    end

    # delete container where isn't needed any more
    def drop_container(container)
      containers.delete(container.id) || raise
    end

    #def run_action(context, action_id, action_args)
    #  context.schedule.action { context.actions.run(action_id, *action_args) }
    #end

    def send_message(message)
      adapter.send_message message
    end

    def receive_message(message)
      if message.type == 'clientHtml'
        message.client_html = html_client
        send_message message
      else
        container(message.container_id).receive_message(message)
      end
    end
  end
end


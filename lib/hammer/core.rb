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

    include Hammer::CurrentApp

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
      @adapter             = options[:adapter] || Adapters::NodeZMQ.new(self)

      @html_client = hammer_builder_pool.get.render(HtmlClient.new(self), :content).to_html!
    end

    # @return [Container] container by user_id (session id is used)
    def container(session_id)
      containers[session_id] ||= Container.new(session_id, self)
    end

    # delete container where isn't needed any more
    def drop_container(container)
      containers.delete(container.id) || raise
    end

    def send_message(message)
      logger.debug ">> #{message}"
      adapter.send_message message
    end

    def receive_message(message)
      logger.debug "<< #{message}"
      if message.type == 'clientHtml'
        message.client_html = html_client
        send_message message
      else
        container(message.container_id).receive_message(message)
      end
    end

    def run
      EventMachine.run do
        logger.info "event machine running"
        Signal.trap("INT") { stop }
        Signal.trap("TERM") { stop }
      end
    end

    private

    def stop
      logger.info 'event machine stopping'
      EventMachine.stop
      logger.info 'event machine stopped'
      adapter.stop
    end
  end
end


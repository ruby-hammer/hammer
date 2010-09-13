# encoding: UTF-8

require 'singleton'

module Hammer::Core
  class Base
    include Hammer::Config

    @containers = {}

    # @return [Container] container by user_id (session id is used)
    def self.container(user_id)
      @containers[user_id] ||= Container.new(user_id)
    end

    # delete container where isn't needed any more
    def self.drop_container(container)
      @containers.delete(container.id) || raise
    end

    # runs websocket server - schedule start after eventmachine startup in thin
    def self.run!
      run_websocket_server
    end

    @fibers_pool = Hammer::Core::FiberPool.new config[:core][:fibers]

    # @return [Hammer::Core::FiberPool]
    def self.fibers_pool
      @fibers_pool
    end

    # tries to execute block safely, errors are logged
    # @yield block to safe execution
    # @return [Boolean] if block was successfully processed
    def self.safely(&block)
      begin
        block.call
      rescue => e
        Hammer.logger.exception e
        return false
      end
      return true
    end

    private

    # schedules tasks depending on what message was received
    # @param [String] message which was received
    def self.receive_message(message, connection)
      session_id = message['session_id']
      context_id = message['context_id']
      action_id = message['action_id']
      form = message['form']

      if !(session_id)
        Hammer.logger.warn "missing session_id"

      # initial request for content
      elsif !(context_id)
        context = self.container(session_id).context(nil, message['hash'])
        context.set_connection(connection)

      # request to do something
      elsif action_id || form
        context = self.container(session_id).context(context_id)
        context.schedule { context.update_form(form).run_action(action_id, message['arguments']) }

      # restart context
      elsif context_id
        context = self.container(session_id).restart_context(context_id, message['hash'], connection)
      else
        Hammer.logger.warn "Non valid message: #{message}"
      end
    end

    # setups websocket server
    def self.run_websocket_server
      EM.epoll
      EM.schedule do
        EventMachine::start_server \
            config[:websocket][:host],
            config[:websocket][:port],
            Hammer::Core::WebSocket::Connection,
            :debug => config[:websocket][:debug] do |connection|

          connection.onopen    { Hammer.logger.debug "WebSocket connection opened" }
          connection.onmessage { |message| receive_message(message, connection) }
          connection.onclose do
            safely do
              Hammer.logger.debug "WebSocket connection closed"
              Context.by_connection(connection).try :drop
            end
          end
        end

        Hammer.logger.info '== Hammer WebSocket running.'

        EventMachine::add_periodic_timer(60) do # TODO now useless
          safely do
            # drops contexts without connections
            contexts = Context.send(:no_connection_contexts)
            unless contexts.empty?
              Hammer.logger.debug "Dropping #{contexts.size} context without connection"
              contexts.each {|c| c.drop }
            end
          end
        end
      end
    end
  end
end

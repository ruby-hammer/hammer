puma = begin
  require 'em-websocket'
  require 'puma'
  require 'rack'
  true
rescue LoadError
  false
end

if puma
  module Hammer::Core::MessageAdapters
    class EmWebSocket < Abstract
      def self.name
        'em-websocket'
      end


      #module Watcher
      #  attr_accessor :adapter
      #
      #  def notify_readable
      #    adapter.receive_message_from_backend
      #  end
      #end

      def initialize(core)
        super core

        # TODO this is messy improve
        @connection_by_id         = {}
        @id_by_connection         = {}
        @session_id_by_connection = {}
        @context_id_by_connection = {}
        @connection_by_context_id = {}

        initialize_puma
        initialize_wesocket
      end

      def get_id
        core.generate.id
      end

      def initialize_wesocket
        EventMachine.next_tick do
          EM::WebSocket.run(:host => "0.0.0.0", :port => 3001) do |ws|
            ws.onopen do |handshake|
              session_id                       = CGI::Cookie.parse(handshake.headers['Cookie'])['_session_id'].first
              connection_id                    = get_id
              @connection_by_id[connection_id] = ws
              @id_by_connection[ws]            = connection_id
              @session_id_by_connection[ws]    = session_id
            end

            ws.onclose do
              connection_id = @id_by_connection[ws]
              container_id  = @session_id_by_connection[ws]
              context_id    = @context_id_by_connection[ws]

              receive_message_on_core Hammer::Message.new_from_hash(
                                          :container_id => container_id,
                                          :context_id   => context_id,
                                          :type         => 'drop')

              @connection_by_id.delete connection_id
              @id_by_connection.delete ws
              @session_id_by_connection.delete ws
              @context_id_by_connection.delete ws
              @connection_by_context_id.delete context_id
            end

            ws.onmessage do |message|
              receive_message message do |message|
                message.container_id  = @session_id_by_connection[ws]
                message.connection_id = @id_by_connection[ws]
                message
              end
            end
          end
        end
      end

      def initialize_puma
        port     = core.config.node.web.port
        host     = core.config.node.web.host
        threads  = '0:16'
        min, max = threads.split(':', 2)

        html_client_delivery_app = lambda { |env| [200, { 'Content-Type' => 'text/html' }, [core.html_client]] }
        app                      = Rack::Static.new html_client_delivery_app,
                                                    :root => core.config.app.public,
                                                    #:urls => %w(/css /hammer /lib)
                                                    :urls => %w(/css /hammer /lib) # TODO make configurable
        @puma                    = ::Puma::Server.new app

        logger.info "Puma #{::Puma::Const::PUMA_VERSION} starting..."
        logger.info "* Min threads: #{min}, max threads: #{max}"
        logger.info "* Listening on tcp://#{host}:#{port}"

        @puma.add_tcp_listener host, port
        @puma.min_threads = Integer(min)
        @puma.max_threads = Integer(max)
        @puma.run
      end

      def ready?
        true
      end

      def stop
        logger.info 'Gracefully stopping Puma, waiting for requests to finish'
        @puma.stop(true)
        logger.info 'Puma stopped.'
      end

      def js_scripts
        %w( /hammer/websocket_message_adapter.js)
      end

      def send_message_to_backend(json, message = nil)
        if (connection = @connection_by_id[message.connection_id] || @connection_by_context_id[message.context_id])
          if message.context_id
            @context_id_by_connection[connection]         = message.context_id
            @connection_by_context_id[message.context_id] = connection
          end
          connection.send json
          true
        else
          false
        end
      end

    end
  end
end
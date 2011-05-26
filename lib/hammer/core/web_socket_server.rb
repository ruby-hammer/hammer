module Hammer::Core
  class WebSocketServer
    include Hammer::Config

    # runs websocket server - schedule start after eventmachine startup in thin
    def self.run!
      run_websocket_server
    end

    private

    # TODO message API
    # { session_id
    #   context_id
    #   actions => {id => args}, ..
    #   values => {id => val}, ..
    #   commands => [force_update| ??]
    # }


    def self.parse_message(message)
      # TODO parse and check type
      [ message['session_id'],
        message['context_id'],
        { message['action_id'] => message['args'] },
        message['form']
      ]
    end

    # schedules tasks depending on what message was received
    # @param [String] message which was received
    def self.receive_message(message, connection)
      session_id, context_id, actions, values = parse_message(message)
      if !(session_id)
        Hammer.logger.warn "missing session_id"

        # initial request for content
      elsif !(context_id) # TODO remove render everything the first time
        context = Hammer::Core::Base.container(session_id).context(nil, message['hash'])
        context.set_connection(connection)

      elsif values
        Hammer::Core::Base.update_values(session_id, context_id, values)
      elsif actions
        Hammer::Core::Base.run_actions(session_id, context_id, actions)
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
            Hammer.safely do
              Hammer.logger.debug "WebSocket connection closed"
              Context.by_connection(connection).try :drop
            end
          end
        end

        Hammer.logger.info '== Hammer WebSocket running.'
      end
    end
  end
end
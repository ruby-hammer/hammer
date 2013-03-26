zmq = begin
  require 'zmq'
  true
rescue LoadError
  false
end

if zmq

  module Hammer::Core::MessageAdapters
    class NodeZMQ < Abstract
      def self.name
        'node_zmq'
      end

      module Watcher
        attr_accessor :adapter

        def notify_readable
          adapter.receive_message_from_backend
        end
      end

      def initialize(core)
        super core

        EventMachine.next_tick do
          @context   = ZMQ::Context.new(1)
          @push_sock = @context.socket(ZMQ::PUSH)
          @push_sock.bind(core.config.node.to_node)
          logger.info "zmq bound #{core.config.node.to_node}"

          @pull_sock = @context.socket(ZMQ::PULL)
          @pull_sock.connect(core.config.node.to_hammer)
          logger.info "zmq connected #{core.config.node.to_hammer}"

          file_descriptor          = @pull_sock.getsockopt ZMQ::FD
          @watcher                 = EventMachine.watch file_descriptor, Watcher
          @watcher.notify_readable = true
          @watcher.adapter         = self
        end
      end

      def ready?
        true
      end

      def stop
        logger.info 'zmq closing'
        @push_sock.close
        @pull_sock.close
        @context.close
        logger.info 'zmq closed'
      end

      def js_scripts
        %w( /socket.io/socket.io.js /hammer/socket_io_message_adapter.js )
      end

      def send_message_to_backend(json, message = nil)
        @push_sock.send(json, ZMQ::NOBLOCK)
      end

      def receive_message_from_backend
        loop do
          events = @pull_sock.getsockopt ZMQ::EVENTS
          break unless events & 1 == 1 # could not find the right constatn on ZMQ
          json = @pull_sock.recv(ZMQ::NOBLOCK)
          if json
            receive_message json do |message|
              if message.type == 'clientHtml'
                message.client_html = core.html_client
                send_message message
                return nil # so nothing is send to core
              else
                message
              end
            end
          end
        end
      end
    end
  end

# ZMQ constants
#Error ZMQ::Error
#Context ZMQ::Context
#Socket ZMQ::Socket
#HWM 1
#SWAP 3
#AFFINITY 4
#IDENTITY 5
#SUBSCRIBE 6
#UNSUBSCRIBE 7
#RATE 8
#RECOVERY_IVL 9
#MCAST_LOOP 10
#SNDBUF 11
#RCVBUF 12
#SNDMORE 2
#RCVMORE 13
#FD 14
#EVENTS 15
#TYPE 16
#LINGER 17
#RECONNECT_IVL 18
#BACKLOG 19
#RECONNECT_IVL_MAX 21
#RECOVERY_IVL_MSEC 20
#NOBLOCK 1
#PAIR 0
#SUB 2
#PUB 1
#REQ 3
#REP 4
#XREQ 5
#XREP 6
#DEALER 5
#ROUTER 6
#PUSH 8
#PULL 7
#UPSTREAM 7
#DOWNSTREAM 8


end
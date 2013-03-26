module Hammer::Core::MessageAdapters
  require 'hammer/core/message_adapters/abstract'
  require 'hammer/core/message_adapters/node_zmq'
  require 'hammer/core/message_adapters/em_web_socket'

  extend Hammer::Utils::FindAdapter
end
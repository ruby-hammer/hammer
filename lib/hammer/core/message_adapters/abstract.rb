module Hammer::Core::MessageAdapters
  class Abstract < Hammer::Core::AbstractAdapter

    abstract!

    attr_reader :core, :logger

    def initialize(core)
      @core   = core
      @logger = core.logging['adapter']
    end

    def js_scripts
      raise NotImplementedError
    end

    def ready?
      raise NotImplementedError
    end

    def stop
      raise NotImplementedError
    end

    # @param [Hammer::Message] message
    def send_message(message)
      before_send_message message
      json = encode_message(message)
      if ready? && send_message_to_backend(json, message)
        logger.debug "<< #{json}"
      else
        logger.warn "dropping message: #{message.to_hash.pretty_inspect.chop!}"
      end
    end

    def encode_message(message)
      MultiJson.dump(message.to_hash)
    end

    def before_send_message(message)
    end

    def send_message_to_backend(json, message = nil)
      raise NotImplementedError
    end

    # @param [String] json
    # @yield postprocess message before sending to core, return nil if message should not be send
    def receive_message(json, &block)
      logger.debug ">> #{json}"
      message = parse_message(json)
      message = block.call message if block && message
      receive_message_on_core message
    end

    def receive_message_on_core message
      core.receive_message message if message
    end

    # override to redirect message
    # if method returns nil message is not send to core
    def before_receive_message(message)
      message
    end

    def parse_message(unparsed_message)
      return Hammer::Message.new_from_json_hash MultiJson.load(unparsed_message)
    rescue MultiJson::LoadError => e
      logger.exception e
      return nil
    end

  end
end
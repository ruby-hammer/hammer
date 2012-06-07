module Hammer::Core::Adapters
  class Abstract
    attr_reader :core, :logger

    def initialize(core)
      @core    = core
      @logger  = core.logging['adapter']
    end

    def send_message(message)
      hash = message.to_hash
      json = Yajl.dump(hash)
      if ready? && _send_message(json)
        logger.debug "<< #{json}"
      else
        logger.warn "dropping message: #{hash.pretty_inspect.chop!}"
      end
    end

    def receive_message(unparsed_message)
      logger.debug ">> #{unparsed_message}"
      message = Yajl.load unparsed_message
      core.receive_message Hammer::Message.new(message)
    rescue Yajl::ParseError => e
      logger.exception e
    end
  end

  protected

  def ready?
    raise NotImplementedError
  end

  def _send_message(message)
    raise NotImplementedError
  end
end
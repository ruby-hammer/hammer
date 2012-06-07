module Hammer
  class Core
    #class Shared # TODO review
    #  include Hammer::Observable::Helper
    #end

    # Manages all context of one user.
    # This is the one object which is stored in session.
    class Container
      attr_reader :id, :core, :context_class, :logger #:shared

      def initialize(id, core, options = { })
        @id            = id
        @contexts      = { }
        #@shared        = options[:shared] || core.config.app.shared.constantize.new
        @core          = core
        @context_class = options[:context_class] || core.config.app.context.constantize
        @logger        = core.logging['container']

        logger.debug "new #{id}"
      end

      def context(id)
        @contexts[id]
      end

      def create_context(url = nil)
        id            = core.generate.secure_id
        @contexts[id] = context_class.new(id, self, url)
      end

      # @param [Context] context to drop when is not needed
      def drop_context(context)
        @contexts.delete(context.id)
        drop if @contexts.empty?
      end

      # drops container when is not needed
      def drop
        core.drop_container(self)
      end

      # context's count
      def size
        @contexts.size
      end

      def receive_message(message)
        case message.type
          when 'initContext'
            context            = create_context(message.url)
            message.context_id = context.id
            send_message message
          else
            if (context = context(message.context_id))
              context.receive_message(message)
            else
              logger.warn "no context with id: #{message.context_id}"
            end
        end
      end

      def send_message(message)
        core.send_message(message)
      end

    end
  end
end

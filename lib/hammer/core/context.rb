# encoding: UTF-8

module Hammer::Core

  # represents context of user, each tab of browser has one of its own
  class AbstractContext
    include Hammer::Config

    attr_reader :id, :connection, :container, :hash, :root_component

    # @param [String] id unique identification
    def initialize(id, container, hash = '')
      @id, @container, @hash = id, container, hash
      schedule { @root_component = root_class.new }
    end

    # remove context form container
    def drop
      container.drop_context(self)
    end

    # @return [Class] class of a root component
    def root_class
      @root_class ||= unless @hash == config[:core][:devel]
        config[:root].to_s.constantize
      else
        Hammer::Component::Developer::Tools
      end
    end

    def location_hash
      root_class == Hammer::Component::Developer::Tools ? config[:core][:devel] : ''
    end

    # renders html, similar to Erector::Widget#to_html
    def to_html
      @root_component.to_html
    end

    # updates values in form parts
    # @param [Hash] hash ['form'] part of message form client
    # @return self
    def update_form(hash)
      Hammer.benchmark "Updating form" do
        return self unless hash && hash.kind_of?(Hash)
        hash.each do |id, values|
          form_part = Hammer::Core.component_by_id(id)
          if form_part
            values.each {|key, value| form_part.set_value(key, value) }
          else
            Hammer.logger.debug "missing form with id: #{id.to_i} for values: #{values.inspect}"
          end
        end
      end
      self
    end

    # @return [Array<Hammer::Bomponent::Base>] of unsended components
    def unsended_components
      root_component.all_children.select(&:unsended?) # TODO can be slow prestore unsended components in a array
    end

  end

  class Context < AbstractContext
    module Actions
      def self.included(base)
        base.send :attr_reader, :actions
      end

      def initialize(id, container, hash = '')
        @actions = Hammer::Weak::Hash[:value].new
        super
      end

      # registers action in context's hash
      # @param [Component::Base] component where action is stored and evaluated
      # @param [String] uuid of the action
      # @return self
      def register_action(uuid, component)
        @actions[uuid] = component
        self
      end

      # evaluates action with +id+, do nothing when no action
      # @param [String] id of a {Action}
      # @param [String] arg if of a {Hammer::Component::Base}
      # @return self
      def run_action(id, arg)
        return self unless component = @actions[id]
        component.run_action(id, arg)
        self
      end
    end

    module Scheduling

      def initialize(id, container, hash = '')
        @queue = []
        super
      end

      # schedules blocks to be processed one by one for the context
      # @param [Boolean] restart try to restart when error?
      # @yield block to schedule
      def schedule(restart = true, &new_block)
        # FIXME when bug in hammer not in app sometimes cycling
        @queue << new_block if new_block

        return self if @scheduled || !connection # block until connection is obtained

        if block = @queue.shift
          @scheduled = block
          @need_update = true
          Base.fibers_pool.spawn { with_context { safely(restart) do
                block.call
                @scheduled = nil
                schedule restart
              end }}
        elsif @need_update
          @scheduled = :update!
          Base.fibers_pool.spawn { with_context { safely(restart) do
                update!
                @scheduled = nil
                @need_update = false
                schedule restart
              end }}
        end
        self
      end

      private

      # sets context to fiber
      def with_context(&block)
        Fiber.current.hammer_context = self
        block.call
        Fiber.current.hammer_context = nil
      end

      # processes safely block, restarts context when error occurred
      # @yield task to execute
      # @param [Boolean] restart try to restart when error?
      def safely(restart = true, &block)
        unless Base.safely(&block)
          if restart
            container.restart_context id, hash, connection,
                "We are sorry but there was a error. Application is reloaded"
          else
            warn("Fatal error")
          end
        end
      end
    end

    module Connection
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # @param [WebSocket::Connection] connection to find out by
        # @return [Context] by +connection+
        def by_connection(connection)
          contexts_by_connection[connection]
        end

        def contexts_by_connection
          @contexts_by_connection ||= {}
        end

        def no_connection_contexts
          @no_connection_contexts ||= []
        end
      end

      def initialize(id, container, hash = '')
        super
        self.class.no_connection_contexts << self
      end

      # store connection to be able to send server-side actualizations
      # @param [WebSocket::Connection] connection
      def set_connection(connection)
        @connection = connection || raise(ArgumentError, 'missing connection')
        self.class.contexts_by_connection[connection] = self
        self.class.no_connection_contexts.delete self
        schedule
        self
      end

      # remove context form container
      def drop
        self.class.contexts_by_connection.delete connection
        self.class.no_connection_contexts.delete self
        super
      end
    end

    module Communication
      # @param [String] warn which will be shown to user using alert();
      # @return self
      def warn(warn)
        @warnings ||= []
        @warnings << warn.to_s
        self
      end

      protected

      # collect updates for the user, builds and send message
      def update!(message = {})
        message[:js] = "alert('#{@warnings.join("\n")}');" unless @warnings.blank?
        @warnings = []
        message[:context_id] = id

        Hammer.benchmark('Actualization') do
          message[:update] = unsended_components.map {|c| c.send!; c.to_html }.join
        end

        # FIXME don't send blank updates
        connection.send message if connection # FIXME unsended will be lost
        self
      end
    end

    include Actions
    include Scheduling
    include Connection
    include Communication
  end
end

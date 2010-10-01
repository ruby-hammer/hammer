# encoding: UTF-8

module Hammer::Core

  # represents context of user, each tab of browser has one of its own
  class AbstractContext
    include Hammer::Config

    attr_reader :id, :connection, :container, :hash, :root_component, :repository

    # @param [String] id unique identification
    def initialize(id, container, hash = '')
      @id, @container, @hash, @repository = id, container, hash, DataMapper.repository(:default)
      restart
    end

    def restart
      schedule(false) { @root_component = root_class.new }
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

    # @return [Array<Hammer::Bomponent::Base>] of unsent? visible components
    def unsent_components
      root_component.all_children.select(&:unsent?)
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
        @queue << [new_block, restart] if new_block

        return self if @scheduled || !connection # block until connection is obtained

        if pair = @queue.shift
          block, restart = pair
          @scheduled = block
          @need_update = restart
          schedule_block restart do
            begin
              block.call
            ensure
              @scheduled = nil
              schedule
            end
          end
        elsif not @need_update.nil?
          @scheduled = :update!
          schedule_block @need_update do
            begin
              update!
            ensure
              @scheduled = nil
              @need_update = nil
              schedule
            end
          end
        end
        self
      end

      private

      def schedule_block(restart, &block)
        Base.fibers_pool.spawn { with_context { safely(restart) { @repository.scope &block }}}
      end

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
            Hammer.logger.error("context restarted")
            warn "We are sorry but there was a error. Application is reloaded"
            self.restart
          else
            Hammer.logger.error("fatal error")
            warn "Fatal error"
            send_message add_warn
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
      def update!(message = setup_message)
        add_warn message
        add_updates message
        send_message message
      end

      private

      # @return [Hash] message
      def setup_message
        { :context_id => id }
      end

      # @return [Hash] message
      def add_warn(message = setup_message)
        message[:js] = "alert('#{@warnings.join("\n")}');" unless @warnings.blank?
        @warnings = []
        message
      end

      # @return [Hash] message
      def add_updates(message = setup_message)
        Hammer.benchmark('Actualization') do
          message[:update] = unsent_components.map {|c| c.send!.to_html }.join
        end
        message
      end

      # @return self
      def send_message(message)
        # FIXME don't send blank updates
        connection.send message if connection # FIXME when no connection message will be lost
        self
      end
    end

    include Actions
    include Scheduling
    include Connection
    include Communication
  end
end

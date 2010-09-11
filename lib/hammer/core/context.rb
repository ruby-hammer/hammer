# encoding: UTF-8

module Hammer::Core

  module Actions
    def self.included(base)
      base.send :attr_reader, :actions
    end

    def initialize(id, container, hash = '')
      super
      @actions = Hammer::Weak::Hash[:value].new
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

  class Message
    attr_reader :context
    def initialize(context)
      @context, @message = context, {}
    end

    # collect updates for the user and stores it in {Message}
    def collect_updates
      Hammer.benchmark('Actualization') do
        @message[:update] = context.unsended_components.map {|c| c.send!; c.to_html }.join
      end
      self
    end

    # adds context id to {Message}. It's used after loading layout.
    def context_id
      @message[:context_id] = context.id
      self
    end

    # sends current message to user through Hammer::Base::Context#connection
    def send!
      context.connection.send @message if context.connection # FIXME unsended will be lost
    end

    # @param [String] warn which will be shown to user using alert();
    # @return self
    def warn(warn)
      @message[:js] = "alert('#{warn}');" if warn
      self
    end
  end

  # represents context of user, each tab of browser has one of its own
  class AbstractContext
    include Hammer::Config

    attr_reader :id, :connection, :container, :hash, :root_component

    # @param [String] id unique identification
    def initialize(id, container, hash = '')
      @id, @container, @hash = id, container, hash
      @queue = []
      self.class.no_connection_contexts << self

      schedule { @root_component = root_class.new }
    end

    # store connection to be able to send server-side actualizations
    # @param [WebSocket::Connection] connection
    def set_connection(connection)
      @connection = connection
      self.class.contexts_by_connection[connection] = self
      self.class.no_connection_contexts.delete self
      self
    end

    # remove context form container
    def drop
      self.class.contexts_by_connection.delete(connection)
      self.class.no_connection_contexts.delete(self)
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

    # @yield block scheduled into fiber_pool for delayed execution
    # @param [Boolean] restart try to restart when error?
    def schedule(restart = true, &block)
      @queue << block
      schedule_next(restart) unless @running # TODO dont schedule if no connection
      self
    end

    # renders html, similar to Erector::Widget#to_html
    def to_html
      @root_component.to_html
    end

    # @param [WebSocket::Connection] connection to find out by
    # @return [Context] by +connection+
    def self.by_connection(connection)
      contexts_by_connection[connection]
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

    # @return [Message] new instance
    def new_message
      Message.new self
    end

    # @return [Array<Hammer::Bomponent::Base>] of unsended components
    def unsended_components
      root_component.all_children.select(&:unsended?)
    end

    private

    # processes safely block, restarts context when error occurred
    # @yield task to execute
    # @param [Boolean] restart try to restart when error?
    def safely(restart = true, &block)
      unless Base.safely(&block)
        if restart
          container.restart_context id, hash, connection,
              "We are sorry but there was a error. Application is reloaded"
        else
          warn("Fatal error").send!
        end
      end
    end

    # sets context to fiber
    def with_context(&block)
      Fiber.current.hammer_context = self
      block.call
      Fiber.current.hammer_context = nil
    end

    # schedules next block from @queue to be processed in {Base.fibers_pool}
    # @param [Boolean] restart try to restart when error?
    def schedule_next(restart = true)
      if block = @queue.shift
        @running = block
        Base.fibers_pool.spawn do
          with_context { safely(restart) { block.call; schedule_next } }
        end
      else
        @running = nil
      end
    end

    def self.contexts_by_connection
      @contexts_by_connection ||= {}
    end

    def self.no_connection_contexts
      @no_connection_contexts ||= []
    end
  end

  class Context < AbstractContext
    include Actions
  end
end

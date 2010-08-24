# encoding: UTF-8

module Hammer::Core

  module Actions
    def initialize(id, container, hash = '')
      super
      @actions = {}
    end

    # creates and stores action for later evaluation
    # @param [Component::Base] component where action will be evaluated
    # @yield the action
    # @return [String] uuid of the action
    def register_action(component, &block)
      uuid = Hammer::Core.generate_id
      @actions[uuid] = Action.new(uuid, component, block)
      return uuid
    end

    # evaluates action with +id+
    # @param [String] id of a {Action}
    # @return self
    def run_action(id)
      (action = @actions[id]) && action.call
      self
    end

    private

    # clears actions for components which are no longer in component tree
    def clear_old_actions
      # TODO remove slow iteration
      components = root_component.all_children
      @actions.delete_if do |key, action|
        not components.include? action.component
      end
    end
  end

  # represents context of user, each tab of browser has one of its own
  class AbstractContext
    include Observable
    include Hammer::Config

    observable_events :drop

    attr_reader :id, :connection, :container, :hash, :root_component

    # @param [String] id unique identification
    def initialize(id, container, hash = '')
      @id, @container, @hash = id, container, hash
      @queue, @message = [], {}
      self.class.no_connection_contexts << self

      schedule { @root_component = root_class.new }
    end

    # store connection to be able to send server-side actualizations
    # @param [WebSocket::Connection] connection
    def connection=(connection)
      @connection = connection
      self.class.contexts_by_connection[connection] = self
      self.class.no_connection_contexts.delete self
    end

    # remove context form container
    def drop
      self.class.contexts_by_connection.delete(connection)
      self.class.no_connection_contexts.delete(self)
      container.drop_context(self)
      notify_observers(:drop, self)
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

    # renders update for the user and stores it in {#message}
    # @option options [Boolean] :partial
    def update(options = {})
      options.merge!(:partial => true) {|_,old,_| old }
      clear_old_actions
      Hammer.benchmark('Actualization') do
        message (options[:partial] ? :update : :html) => self.to_html(:update => options[:partial])
      end
      self
    end

    # adds context id to {#message}. It's used after loading layout.
    def send_id(connection)
      self.connection = connection
      message :context_id => self.id
      self
    end

    # sends current message to user through {#connection}
    def send!
      connection.send message if connection # FIXME unsended will be lost
      @message.clear
    end

    # @yield block scheduled into fiber_pool for delayed execution
    # @param [Boolean] restart try to restart when error?
    def schedule(restart = true, &block)
      @queue << block
      schedule_next(restart) unless @running
      self
    end

    # renders html, similar to Erector::Widget#to_html
    # @param [Hash] options
    def to_html(options = {})
      @root_component.to_html(options)
    end

    # @param [WebSocket::Connection] connection to find out by
    # @return [Context] by +connection+
    def self.by_connection(connection)
      contexts_by_connection[connection]
    end

    # @param [String] warn which will be shown to user using alert();
    # @return self
    def warn(warn)
      message :js => "alert('#{warn}');" if warn
      self
    end

    # updates values in form parts
    # @param [Hash] hash ['form'] part of message form client
    # @return self
    def update_form(hash)
      Hammer.benchmark "Updating form" do
        return self unless hash && hash.kind_of?(Hash)
        hash.each do |id, values|
          form_part = begin ObjectSpace._id2ref(id.to_i) rescue RangeError end
          # FIXME dangerous
          if form_part
            values.each {|key, value| form_part.set_value(key, value) }
          else
            Hammer.logger.debug "missing form with id: #{id.to_i} for values: #{values.inspect}"
          end
        end
      end
      self
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

    # @return [Hash] current message stored to {#send!}
    # @param [Hash] hash to be merged into current message
    def message(hash = {})
      @message.merge! hash
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

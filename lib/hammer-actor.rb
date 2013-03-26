# DONE finishing
# DONE wait for response
# DONE futures
# DONE supervision
# DONE remove reference and move methods to private
# DONE supervise shared workers, collect errors from threads
# DONE add wrapper for calling methods on objects
# DONE references
# TODO message definition
# TODO smarter message filtering
# TODO errors
# TODO deadlock detection?
# TODO push unhandled messages at the end?
# TODO remote actors?


require 'thread'
require 'set'

class Set
  def shift
    return nil if empty?
    @hash.shift[0]
  end
end

module Hammer
  module Actor
    DEBUG  = false
    ASSERT = false

    def self.enable_assert_mode
      const_set :ASSERT, true
    end

    def self.current
      Thread.current[:__current_actor__]
    end

    def self.define_message(*attributes)
      Class.new do
        attr_reader(*attributes)
        define_method :initialize do |*values|
          attributes.zip(values) do |attr, val|
            instance_variable_set "@#{attr}", val
          end
        end
      end
    end

    class AbstractReference
      attr_reader :_actor

      def initialize(actor)
        @_actor = actor
        # create method delegations for behaviors
      end
    end

    class Reference < AbstractReference
      [:tell, :<<, :tell_and_wait, :tell_and_future, :join, :stop, :failed_with_error, :supervise_by,
       :stopped?, :stopping?].each do |method|
        define_method method do |*args|
          _actor.public_send method, *args
        end
      end
    end

    #class Behavior
    #  attr_accessor :actor
    #
    #  def on_tell(message, response)
    #  end
    #
    #  def accept_message?
    #    false
    #  end
    #
    #  def on_message
    #    raise NotImplementedError
    #  end
    #
    #  def receive_next_message?
    #    true
    #  end
    #
    #  def delegate
    #    []
    #  end
    #end
    #
    #class Stoppable < Behavior
    #  Stop = Actor.define_message
    #
    #  def initialize
    #    @stopping       = false
    #    @stopped_future = Future.new
    #  end
    #
    #  def on_tell
    #
    #  end
    #
    #  def accept?(message)
    #
    #  end
    #
    #  def on_message(message)
    #
    #  end
    #
    #  def receive_next_message?
    #
    #  end
    #
    #  def delegate
    #    [:stop]
    #  end
    #
    #  def stopped?
    #    @stopped_future.ready?
    #  end
    #
    #  def stopping?
    #    @stopping
    #  end
    #
    #  def stop
    #    actor.tell Stop.new
    #    @stopping = true
    #  end
    #
    #end

    class Future
      def initialize
        @queue = Queue.new
        @value = nil
        @ready = false
        @mutex = Mutex.new
      end

      def ready?
        @ready
      end

      def set(result)
        raise 'future already happen' if ready?
        @queue << result
        @ready = true # TODO JRuby volatile? is it a problem?
        self
      end

      alias_method :<<, :set

      def value
        @value || @mutex.synchronize { @value ||= @queue.pop }
      end
    end

    class Abstract
      attr_reader :mailbox
      attr_reader :reference
      alias_method :ref, :reference

      ActorMessage = Actor.define_message :body, :future

      def self.new(*args, &block)
        super(*args, &block).reference
      end

      def initialize
        @mailbox        = Queue.new
        @reference      = create_reference
        #@behaviours = behaviors
        #@behaviours.each { |b| b.actor = self }
        @stopping       = false
        @stopped_future = Future.new
        @supervisor     = nil
      end

      def stopped?
        @stopped_future.ready?
      end

      def stopping?
        @stopping
      end

      def stop
        self << Stop.new
        @stopping = true
        reference
      end

      def supervise_by(actor)
        self.tell Link.new(actor)
      end

      def tell(message, response = nil)
        raise 'actor is stopping or stopped, do not send any more messages' if stopping?
        #call_callback :on_tell, message, response
        future = (response ? Future.new : nil)
        puts "stored #{message} in #{self} and #{response}" if DEBUG
        @mailbox << ActorMessage.new(message, future)
        after_tell

        return case response
               when nil
                 reference
               when :future
                 future
               when :value
                 future.value
               else
                 raise ArgumentError, 'response'
               end
      end

      def tell_and_wait(message)
        tell message, :value
      end

      def tell_and_future(message)
        tell message, :future
      end

      alias_method :<<, :tell

      Stop   = Actor.define_message
      Link   = Actor.define_message :supervisor
      Failed = Actor.define_message :actor, :message, :error

      def on_message(message)
        raise NotImplementedError
      end

      def join
        stop
        @stopped_future.value
        return reference
      end

      protected

      def receive_internal_message(message)
        case message
        when Stop
          set_as_stopped
        when Link
          @supervisor = message.supervisor
        else
          on_message message
        end
      end

      def after_tell
      end

      def create_reference
        Reference.new(self)
      end

      CALLBACKS = [:on_tell, :accept_message?, :on_message]

      private

      #def call_callback(name, *args) # TODO cache
      #  @behaviours.each { |behavior| behavior.send name, *args }
      #end

      def receive
        message              = @mailbox.pop
        message_body, future = message.body, message.future
        puts "received #{message_body} in #{self}" if DEBUG
        result = receive_internal_message message_body
        future.set result if future
        self
      rescue => error
        if @supervisor
          @supervisor.tell Failed.new(self, message_body, error)
        else
          $stderr.puts "#{error.message} (#{error.class})\n#{error.backtrace * "\n"}"
        end
        set_as_stopped
      end

      def set_as_stopped
        #@stopping = true
        @stopped_future.set true
      end
    end

    class Threaded < Abstract
      def initialize
        super()
        spawned = Future.new
        @thread = Thread.new do
          Thread.current[:__current_actor__] = reference
          spawned << true
          receiving
        end
        def @thread.inspect
          super.gsub '>', " #{self[:__current_actor__]._actor.class}>"
        end
        spawned.value
      end

      private

      def receiving
        loop do
          break if stopped?
          receive
        end
      end
    end

    class Shared < Abstract
      class Worker < Threaded
        def initialize(executor)
          super()
          @executor = executor
        end

        def on_message(message)
          case message
          when Work
            actor = message.actor
            kidnap_thread_to_actor(actor) do
              raise if ASSERT && actor.mailbox.empty?
              raise if ASSERT && actor.stopped?
              actor.send :receive
            end
            @executor << Finished.new(actor, self)
          else
            raise 'wrong message'
          end
        end

        private

        def kidnap_thread_to_actor(actor)
          raise if ASSERT && !actor.kind_of?(Abstract)
          Thread.current[:__current_actor__] = actor.reference
          yield
        ensure
          Thread.current[:__current_actor__] = reference
        end
      end

      class Executor < Threaded
        attr_reader :worker_pool_size

        def initialize(worker_pool_size = 20)
          super()
          @worker_pool_size = worker_pool_size
          @free_workers     = Array.new(worker_pool_size) { Worker.new self }
          @active_actors    = Set.new # actors being worked on
          @waiting_actors   = Set.new # actors with waiting messages
          @free_workers.each do |worker|
            worker.supervise_by self
          end
        end

        def on_message(message)
          raise if ASSERT && !(@active_actors & @waiting_actors).empty?
          case message
          when Ready
            actor = message.actor
            unless @active_actors.include?(actor)
              @waiting_actors << actor
              raise if ASSERT && actor.mailbox.empty?
              try_assign_work
            end

          when Finished
            actor, worker = message.actor, message.worker
            @free_workers << worker
            @active_actors.delete actor
            case
            when actor.mailbox.empty?
              # do nothing, forget the actor
            when actor.stopped?
              # do nothing, forget the actor
            else
              @waiting_actors << actor
            end
            try_assign_work
          when Failed
            $stderr.puts "Woker failed #{message.actor} with error\n" +
                             "#{message.error.message} (#{message.error.class})\n#{message.error.backtrace * "\n"}"
            @free_workers << Worker.new(self)
          end
        end

        private

        def try_assign_work
          unless @free_workers.empty? || @waiting_actors.empty?
            actor = @waiting_actors.shift
            @active_actors.add actor
            @free_workers.pop << Work.new(actor)
          end
        end
      end

      Ready    = Actor.define_message :actor
      Work     = Actor.define_message :actor
      Finished = Actor.define_message :actor, :worker

      def self.executor
        if superclass.respond_to? :executor
          superclass.executor
        else
          @executor ||= Executor.new
        end
      end

      protected

      def after_tell
        raise if ASSERT && mailbox.empty?
        self.class.executor << Ready.new(self)
      end
    end

    module Simple
      def initialize(&block)
        super()
        @on_message_block = block
      end

      def on_message(message)
        @on_message_block.call(message)
      end
    end

    class SimpleThreaded < Threaded
      include Simple
    end

    class SimpleShared < Shared
      include Simple
    end

    class WrapperReference < AbstractReference
      class Proxy
        def initialize(wrapper, response)
          @wrapper  = wrapper
          @response = response
        end

        def method_missing(method, *args, &block)
          if base_respond_to? method
            @wrapper._actor.tell Wrapper::CallMethod.new(method, args, block), @response
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          base_respond_to?(method_name) || super(method_name, include_private)
        end

        def base_respond_to?(method_name)
          @wrapper.base_respond_to? method_name
        end
      end

      attr_reader :in_future, :async, :sync

      def initialize(actor)
        super actor
        @in_future = Proxy.new self, :future
        @sync      = Proxy.new self, :value
        @async     = Proxy.new self, nil
      end

      def method_missing(method, *args, &block)
        if base_respond_to? method
          _actor.tell_and_wait Wrapper::CallMethod.new(method, args, block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        base_respond_to?(method_name) || super(method_name, include_private)
      end

      def base_respond_to?(method_name)
        _actor.base.respond_to? method_name
      end
    end

    module Wrapper
      def self.included(base)
        base.send :attr_reader, :base
      end

      def initialize(base)
        super()
        @base = base
      end

      CallMethod = Actor.define_message :method, :args, :block

      def on_message(message)
        if CallMethod === message
          @base.public_send message.method, *message.args, &message.block
          # TODO return exceptions and raise them in remote caller when waiting for result
        else
          raise "unknown message #{message}"
        end
      end

      def create_reference
        WrapperReference.new(self)
      end
    end

    class ThreadedWrapper < Threaded
      include Wrapper
    end

    class SharedWrapper < Shared
      include Wrapper
    end

  end
end
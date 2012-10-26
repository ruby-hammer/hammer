require 'hammer/fiber'

class Hammer::Core
  class Fiber < ::Fiber
    attr_accessor :hammer_app, :id
  end

  class FiberPool
    Runnable = Struct.new(:app, :block)

    # gives access to the currently free fibers
    attr_reader :fibers

    # Prepare a list of fibers that are able to run different blocks of code
    # every time. Once a fiber is done with its block, it attempts to fetch
    # another one from the queue
    def initialize(count = 50)
      @busy_fibers = {}
      @queue = []

      @fibers = Array.new(count) do |i|
        Fiber.new do |runnable|
          Fiber.current.id = i
          loop do
            run_with_app runnable
            unless @queue.empty?
              runnable = @queue.shift
            else
              @busy_fibers.delete(Fiber.current.object_id)
              @fibers << Fiber.current
              runnable = Fiber.yield
            end
          end
        end
      end
    end

    # If there is an available fiber use it, otherwise, leave it to linger in a queue
    def spawn(app, &block)
      if fiber = @fibers.shift
        @busy_fibers[fiber.object_id] = fiber
        fiber.resume(Runnable.new(app, block))
      else
        @queue << Runnable.new(app, block)
      end
      self # we are keen on hiding our queue
    end

    private

    def current_app=(app)
      Fiber.current.hammer_app = app
    end

    def run_with_app(runnable)
      self.current_app = runnable.app
      runnable.block.call
    ensure
      self.current_app = nil
    end

  end # FiberPool
end


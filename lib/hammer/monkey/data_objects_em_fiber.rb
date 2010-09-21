require 'fiber'
MAIN_FIBER = Fiber.current

module Hammer
  module DataObjectsEMFiber
    def execute_non_query(*args)
      f = Fiber.current
      return super if f == MAIN_FIBER

      EventMachine.defer(
        proc do
          begin
            super
          rescue Exception => e
            e
          end
        end,
        proc do |r|
          f.resume(r)
        end
      )

      r = Fiber.yield
      if r.kind_of?(Exception)
        r.set_backtrace(caller)
        raise r
      end
      r
    end

    def execute_reader(*args)
      f = Fiber.current
      return super if f == MAIN_FIBER

      EventMachine.defer(
        proc do
          begin
            super
          rescue Exception => e
            e
          end
        end,
        proc do |r|
          f.resume(r)
        end
      )

      r = Fiber.yield
      if r.kind_of?(Exception)
        r.set_backtrace(caller)
        raise r
      end
      r
    end
  end
end

module DataObjects
  class Connection
    private
    def concrete_command
      @concrete_command || begin

        class << self
          private
          def concrete_command
            @concrete_command
          end
        end

        @concrete_command = begin
          driver_namespace.const_get(:FiberedCommand)
        rescue
          command = driver_namespace.const_set(:FiberedCommand, Class.new(driver_namespace.const_get('Command')))
          command.send :include, Hammer::DataObjectsEMFiber
          command
        end
      end
    end
  end
end

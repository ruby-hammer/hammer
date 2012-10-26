module Hammer
  class Apps::Scheduler

    #class Task
    #  attr_reader :block, :name
    #
    #  def initialize(restart, update, name = nil, &block)
    #    @restart = restart
    #    @update  = update
    #    @name    = name
    #    @block   = block
    #  end
    #
    #  def restart?
    #    @restart
    #  end
    #
    #  def update?
    #    @update
    #  end
    #
    #  def to_s
    #    "<#Hammer::Core::Context::Scheduler::Task #{name} #{object_id}>"
    #  end
    #end

    attr_reader :app

    def initialize(app, options = { })
      @app       = app
      @queue     = []
      @scheduled = nil
      @update    = false

      #update_block = lambda { context.communicator.update! }
      #@update = Task.new(true, false, 'update', &update_block)
      #@update_after_restart = Task.new(false, false, 'update_after_restart', &update_block)
      #
      #@fatal_error = Task.new(false, false, 'fatal_error') do
      #  core.logger.error("fatal error")
      #  context.communicator.warn "Fatal error"
      #  context.communicator.update!(:skip_updates => true)
      #end
      #
      #@restart = Task.new(false, false, 'restart') do
      #  core.logger.error("context restarted")
      #  context.communicator.warn "We are sorry but there was a error. Application is reloaded"
      #  context.restart
      #  run &update_after_restart.block
      #end
    end

    def core
      app.context.container.core
    end

    def scheduled?
      @scheduled
    end

    def action(&block)
      @queue << block
      @update = true
      run
    end

    def update
      @update = true
      run
    end

    # schedules blocks to be processed one by one for the context
    # @yield block to schedule
    #def run(new_task = nil, &new_block)
    #  raise if new_task && new_block
    #  @queue << new_task || Task.new(true, true, &new_block) if new_task || new_block
    #
    #  return if scheduled
    #
    #  if task = @queue.shift
    #    @scheduled = task
    #    sleep 1
    #    core.fiber_pool.spawn &method(:running)
    #  end
    #  self
    #end

    def run
      return if scheduled?

      if (task = @queue.shift)
      elsif @update
        task = lambda do
          @update = false
          app.send_updates
        end
      else
        return
      end

      @scheduled = task
      core.fiber_pool.spawn app, &method(:running)
    end

    #def restart!
    #  run restart
    #end
    #
    #def update!
    #  run update
    #end

    private

    #attr_reader :restart, :update, :update_after_restart, :fatal_error, :scheduled
    attr_reader :scheduled

    #def running
    #  puts "running #{scheduled}"
    #  result = core.safely do
    #    context.repository.scope &scheduled.block
    #  end
    #
    #  if result
    #    update! if scheduled.update? && @queue.empty? # if ok try update
    #  else
    #    if scheduled.restart? # deal with error
    #      restart!
    #    else
    #      run fatal_error
    #    end
    #  end
    #ensure
    #  @scheduled = nil
    #  run
    #end

    def running
      success, result_or_exception = Utils.safely do
        #core.benchmark "running: #{scheduled.inspect}" do
        #  context.repository.scope &scheduled
        #end
        Utils.benchmark app.logger, :debug, "running: #{scheduled.inspect}", &scheduled
        #scheduled.call
        #context.update! if @queue.empty?
      end

      @scheduled = nil

      if success
        run
      else
        app.logger.exception result_or_exception
        # TODO what about user, let him know something went wrong, reload context
      end
    end


  end
end


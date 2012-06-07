describe Hammer::Core::Context::Scheduler do
  Scheduler = Hammer::Core::Context::Scheduler

  class FiberPool
    attr_reader :blocks

    def initialize
      @blocks = []
    end

    def spawn(&block)
      @blocks << block
    end

    def run
      @blocks.each do |b|
        b.call
      end
    end
  end

  let :context do
    repository = double('Repository')
    repository.stub(:scope) { |block| block.call }
    double('Context', :repository => repository)
  end

  let :fiber_pool do
    FiberPool.new
  end

  let :scheduler do
    scheduler = Scheduler.new context, :fiber_pool => fiber_pool
    scheduler.stub(:current_context) { context }
    scheduler.stub(:current_context=) { context }
    scheduler
  end

  before do
    $run = nil
  end

  it do
    context.repository.scope { $run = 1 }
    $run.should == 1
  end

  it 'should run block' do
    scheduler.run { $run = true }
    fiber_pool.run
    $run.should == true
  end

end

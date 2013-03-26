require_relative 'minitest_helper'
require 'hammer-actor'

require 'timeout'

Hammer::Actor.enable_assert_mode

class HammerActorTest < MiniTest::Spec

  def timeout
    Timeout::timeout(1) do
      yield
    end
  end

  describe Hammer::Actor::Future do
    it 'should wait for result' do
      timeout do
        future = Hammer::Actor::Future.new
        Thread.new { future.set 1 }
        assert !future.ready?
        future.value.must_equal 1
        assert future.ready?
        future.value.must_equal 1
      end
    end

  end

  actor_classes = [Hammer::Actor::SimpleThreaded, Hammer::Actor::SimpleShared]
  actor_classes.each do |klass|
    describe klass do
      it 'should wait for value' do
        timeout do
          ping = klass.new { |v| v }
          ping.tell_and_wait(1).must_equal 1
        end
      end

      it 'should wait on #join' do
        timeout do
          waiting = klass.new { |t| sleep t }
          start   = Time.now
          waiting << 0.1
          waiting.join
          (Time.now-start).must_be :>, 0.1
        end
      end

      it 'should supervise' do
        timeout do
          bad        = klass.new { |m| raise 'my bad' }
          f          = Hammer::Actor::Future.new
          supervisor = klass.new do |failed|
            f << failed
          end
          bad.supervise_by supervisor
          bad.tell 1

          failed = f.value
          failed.must_be_kind_of Hammer::Actor::Abstract::Failed
          #failed.actor.must_equal bad
          failed.error.message.must_equal 'my bad'
          supervisor.join
        end
      end
    end
  end

  actor_classes = [Hammer::Actor::ThreadedWrapper, Hammer::Actor::SharedWrapper]
  actor_classes.each do |klass|
    describe klass do
      class Base
        def a_method
          'result'
        end

        def b_method(future)
          future.set 'result'
        end
      end

      it 'wraps actor in Hammer::Actor::WrapperReference' do
        wrapper = klass.new(Base.new)
        wrapper.must_be_kind_of Hammer::Actor::WrapperReference
      end

      it 'returns value' do
        wrapper = klass.new(Base.new)
        wrapper.a_method.must_equal 'result'
        wrapper.sync.a_method.must_equal 'result'
      end

      it 'returns future' do
        wrapper = klass.new(Base.new)
        future = wrapper.in_future.a_method
        future.value.must_equal 'result'
      end

      it 'works async' do
        wrapper = klass.new(Base.new)
        future = Hammer::Actor::Future.new
        wrapper.async.b_method(future).must_equal wrapper
        future.value.must_equal 'result'
      end
    end
  end
end


#require 'benchmark'
#
#actors_count = 300_000
#bounce_times = 100
#messages     = 1000
#Benchmark.bmbm(10) do |b|
#  #b.report("#{messages*bounce_times} rand") do
#  #  done   = Queue.new
#  #  actors = Array.new(actors_count) do |i|
#  #    Hammer::Actor::SimpleShared.new do |count|
#  #      if count < bounce_times
#  #        actors[rand(actors_count)] << count + 1
#  #      else
#  #        done << true
#  #      end
#  #    end
#  #  end
#  #
#  #  messages.times { |i| actors[i] << 0 }
#  #  messages.times { |i| done.pop }
#  #end
#
#  b.report(messages*bounce_times) do
#    done   = Queue.new
#    actors = Array.new(actors_count) do |i|
#      Hammer::Actor::SimpleShared.new do |count|
#        if count < bounce_times
#          actors[(i+1) % actors_count] << count + 1
#        else
#          done << true
#        end
#      end
#    end
#
#    messages.times { |i| actors[i] << 0 }
#    messages.times { |i| done.pop }
#  end
#end

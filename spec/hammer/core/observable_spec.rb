# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Core::Observable do
  include HammerMocks

  class AObservable
    include Hammer::Core::Observable
    observable_events :a_event
  end

  let(:a_observable) { AObservable.new }

  describe '.observable_events' do
    subject { AObservable.observable_events }
    it { should == [:a_event] }
  end

  let(:observer) do
    observer = mock(:observer)
    observer.stub(:on_event).and_return { raise 'event called' }
    observer.stub(:context).and_return(context_mock)
    context_mock.stub(:schedule).and_return {|block| block.call }
    observer
  end

  describe '#add_observer' do
    describe '(:a_event, a_observer, a_method)' do
      before { a_observable.add_observer(:a_event, observer, :on_event) }
      it('should add observer') do
        a_observable.get_observers(:a_event).should include(observer)
      end

      describe 'when notified' do
        it { lambda { a_observable.notify_observers :a_event }.should raise_error(RuntimeError, 'event called') }
      end

      describe 'when deleted' do
        before { pp a_observable.get_observers(:a_event); a_observable.delete_observer(:a_event, observer) }
        it { pp a_observable.get_observers(:a_event); a_observable.get_observers(:a_event).should be_blank }
      end
    end

    describe '(:a_event) { raise \'called\' }' do
      before { a_observable.add_observer(:a_event, observer) { raise 'called' }}
      it { lambda { a_observable.notify_observers :a_event }.should raise_error(RuntimeError, 'called') }
    end
  end



end
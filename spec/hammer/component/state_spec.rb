# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Component::State do
  include HammerMocks

  let(:klass) { Class.new(Hammer::Component::Base) }
  let(:instance) do
    instance = klass.new :context => context_mock
    instance.reset!
    instance
  end

  describe 'method a' do
    before do
      klass.class_eval do
        def a; end
      end
    end

    it do
      instance.a
      instance.should_not be_changed
    end

    describe 'when .changing :a' do
      before do
        klass.class_eval { changing :a }
      end
      it do
        instance.a
        instance.should be_changed
      end
    end
  end

  describe 'changing with block' do
    before do
      klass.class_eval do
        def a;end
        changing { def b; end }
        def c;end
      end
    end

    it { instance.a; instance.should_not be_changed }
    it { instance.b; instance.should be_changed }
    it { instance.c; instance.should_not be_changed }
    it { klass.changing_methods.should == [:b] }
  end

  describe 'attr_accessor' do
    before do
      klass.class_eval do
        changing { attr_accessor :a }
      end
    end
    it { klass.changing_methods.should == [:a, :a=] }
  end
end

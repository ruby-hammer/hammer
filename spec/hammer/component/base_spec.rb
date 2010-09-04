# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Component::Base do
  include HammerMocks
  setup_context

  class FooComponent < Hammer::Component::Base
    define_widget :quickly do
      text 'foo content'
    end
  end

  describe '.new' do
    it { lambda {FooComponent.new}.should_not raise_error }
    it { FooComponent.new.context.should == context }
  end

  describe '#to_html' do
    subject { c = FooComponent.new; update c }
    it { should match(/foo content/)}

    describe 'when passed' do
      subject do
        component = Hammer::Component::Base.new
        component.instance_eval { pass_on FooComponent.new }
        update component
      end
      it { should match(/foo content/)}
    end
  end

  describe "#ask" do
    let :component do
      component = Hammer::Component::Base.new
      @asked = component.instance_eval do
        ask(Hammer::Component::Base.new) {|answer| @answer = answer }
      end
      component
    end

    describe "@answer" do
      subject {
        component.instance_variable_get(:@answer)
      }
      it { should be_nil }

      describe 'when answered' do
        before { component; @asked.answer!(:answer) }
        it { should == :answer }
      end
    end
  end

  describe '#widget', '#component' do
    before { @component = FooComponent.new }
    it { @component.widget.component.should == @component }
  end


end

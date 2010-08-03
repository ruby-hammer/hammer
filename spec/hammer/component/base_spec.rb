# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Component::Base do
  include HammerMocks

  class FooComponent < Hammer::Component::Base
    define_widget :quickly do
      text 'foo content'
    end
  end

  describe '.new' do
    it { lambda {FooComponent.new}.should raise_error }
  end

  describe '#to_html' do
    subject { FooComponent.new(:context => context_mock).to_html }
    it { should match(/foo content/)}

    describe 'when passed' do
      subject do
        component = Hammer::Component::Base.new(:context => context_mock)
        component.instance_eval { pass_on FooComponent.new(:context => context) }
        component.to_html
      end
      it { should match(/foo content/)}
    end
  end

  describe "#ask" do
    let :component do
      component = Hammer::Component::Base.new(:context => context_mock)
      @asked = component.instance_eval do
        ask(Hammer::Component::Base.new(:context => context)) {|answer| @answer = answer }
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
    subject { @component = FooComponent.new(:context => context_mock).widget.component;  }
    it { should == @component }
  end


end

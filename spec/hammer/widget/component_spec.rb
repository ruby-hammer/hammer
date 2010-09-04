# encoding: UTF-8 FIXME remove all

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Widget::Component do

  include HammerMocks
  setup_context

  let (:klass) do
    klass = Class.new(Hammer::Widget::Base)
    klass.wrap_in(:span)
    klass
  end

  let(:component_class) do
    klass = Class.new(Hammer::Component::Base)
    klass.class_eval do
      needs :sub => nil
      attr_reader :sub
      define_widget :quickly do
        text 'component'
        render component.sub if component.sub
      end
      widget_class.stub(:css_class).and_return('AComponent')
    end
    klass
  end

  let(:sub_component) { component_class.new :context => context_mock }
  let(:component) { component_class.new :context => context_mock, :sub => sub_component }

  describe '#to_html(:update => true)' do
    subject { update component }
    it { should == "<div class=\"AComponent component\" id=\"#{component.object_id}\">component" +
          "<span data-component-replace=\"#{sub_component.object_id}\"></span></div>" +
          "<div class=\"AComponent component\" id=\"#{sub_component.object_id}\">component</div>" }
  end

end

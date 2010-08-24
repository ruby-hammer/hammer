require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Widget::State do
  include HammerMocks

  let(:component_class) do
    klass = Class.new(Hammer::Component::Base)    
    klass.class_eval do
      needs :sub => nil
      children :sub
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

  describe '#to_html()' do
    subject { component.to_html }
    it { should == "<div class=\"AComponent component changed\" id=\"#{component.object_id}\">component" +
          "<div class=\"AComponent component changed\" id=\"#{sub_component.object_id}\">component</div></div>" }
  end

  describe '#to_html(:update => true)' do
    subject { component.to_html :update => true }
    it { should == "<div class=\"AComponent component changed\" id=\"#{component.object_id}\">component" +
          "<span data-component-replace=\"#{sub_component.object_id}\"></span></div>" +
          "<div class=\"AComponent component changed\" id=\"#{sub_component.object_id}\">component</div>" }
  end


end

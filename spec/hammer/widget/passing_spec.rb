require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Widget::Passing do
  include HammerMocks
  setup_context

  let(:component_class) do
    klass = Class.new(Hammer::Component::Base)
    klass.class_eval do
      needs :sub => nil
      attr_reader :sub
      define_widget do
        def content
          text 'component'
          render component.sub if component.sub
        end
      end
      widget_class.stub(:css_class).and_return('AComponent')
    end
    klass
  end

  let(:sub_component) { component_class.new :context => context_mock }
  let(:passe) { component_class.new :context => context_mock }
  let(:component) { component_class.new :context => context_mock, :sub => sub_component }

  describe 'when passed_on' do
    before { component.pass_on passe }
    it 'component should render passe update' do
      update(component).should ==
          "<div class=\"AComponent component passed\" id=\"#{component.object_id}\">" +
          "<span data-component-replace=\"#{passe.object_id}\"></span></div>" +
          "<div class=\"AComponent component\" id=\"#{passe.object_id}\">component</div>"
    end

    describe 'when retake_control' do
      before { component.retake_control! }
      describe '#to_html' do
        subject { update component }
        it { should == "<div class=\"AComponent component\" id=\"#{component.object_id}\">component" +
              "<span data-component-replace=\"#{sub_component.object_id}\"></span></div>" +
              "<div class=\"AComponent component\" id=\"#{sub_component.object_id}\">component</div>" }
      end
    end
  end
end
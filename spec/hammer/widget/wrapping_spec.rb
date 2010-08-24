# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Widget::Wrapping do
  include HammerMocks

  describe 'a widget', "#to_html", 'when wrapped_in == nil' do
    let(:klass) do
      klass = Class.new(Hammer::Widget::Base)
      klass.wrap_in nil
      klass
    end
    subject { lambda { (@widget = klass.new(:component => component_mock)).to_html }}
    it { should raise_error }
  end

  describe 'a widget', "#to_html", 'when wrapped_in == :span' do
    let(:klass) do
      klass = Class.new(Hammer::Widget::Base)
      klass.stub(:to_s).and_return('AClass')
      klass.wrap_in :span
      klass
    end

    let(:widget) { klass.new :component => component_mock }
    subject { widget.to_html }
    it { should == '<span class="a_class"></span>' }

    describe 'when root widget' do
      let(:widget) { klass.new :component => component_mock, :root_widget => true }
      it { should == "<span class=\"a_class component\" id=\"#{widget.component.object_id}\"></span>" }
    end
  end

  describe ".css_class" do
    subject do
      klass = Class.new(Hammer::Widget::Base)
      klass.stub(:to_s).and_return('AModule::AClass')
      klass.css_class
    end
    it { should == 'a_module-a_class' }
  end

  describe "#to_html", 'when wrappers are set' do
    let(:klass) { Class.new Hammer::Component::Base.widget_class }
    before { klass.stub(:to_s).and_return('AClass') }
    subject { (@widget = klass.new(:component => component_mock, :root_widget => true)).to_html }
    it { should =="<div class=\"a_class component\" id=\"#{@widget.component.object_id}\"></div>" }

    describe 'when subwidget' do
      subject do
        (@widget = klass.new(:component => component_mock, :root_widget => true) do |w|
            w.widget klass
          end).to_html
      end
      it { should == "<div class=\"#{klass.css_class} component\" id=\"#{@widget.component.object_id}\">" +
            "<div class=\"#{klass.css_class}\"></div></div>"}
    end
  end


end

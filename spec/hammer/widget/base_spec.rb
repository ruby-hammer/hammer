# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Widget::Base do
  include HammerMocks
  setup_context

  describe '#render' do
    let (:klass) { Class.new(Hammer::Component::Base) }

    describe "(a_widget)" do
      before do
        klass.class_eval do
          define_widget :A, :Widget do
            wrap_in :span
            def content
              render component.class.widget_class(:B).new :component => component
            end

            def self.css_class; 'a';end
          end

          define_widget :B, :Widget do
            wrap_in :span
            def self.css_class; 'b';end
          end
        end
      end      

      subject do
        @instance = klass.new(:widget_class => :A)
        update @instance
      end
      
      it { should == "<span class=\"#{klass.widget_class(:A).css_class} root component\" id=\"#{@instance.object_id}\">" +
            "<span class=\"#{klass.widget_class(:B).css_class}\"></span></span>"}
    end

    describe "(a_object_responding_to_widget)" do

      before do
        klass.class_eval do
          class ObjectWithWidget
            def widget
              @number = 3
              Erector.inline(:obj => @number) { text @obj }
            end
          end

          define_widget :A, :Widget do
            wrap_in :span
            def content
              render ObjectWithWidget.new
            end
            def self.css_class; 'a';end
          end
        end
      end
      
      subject do
        @instance = klass.new(:widget_class => :A)
        update @instance
      end

      it { should == "<span class=\"#{klass.widget_class(:A).css_class} root component\"" +
            " id=\"#{@instance.object_id}\">3</span>" }
    end
  end
end


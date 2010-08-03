module Hammer::Component::Rendering

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      needs :widget_class => nil
    end
  end

  module ClassMethods
    def widget_classes
      @widget_classes ||= {}
    end

    def widget_class(name = :Widget)
      check_class widget_classes[name] || parent_widget_class(name)
    end

    def define_widget(name = :Widget, parent = nil, &block)
      if name == :quick
        define_widget { define_method :content, &block }
      else
        parent = parent_widget_class(parent || name)
        widget_classes[name] = widget_class = const_set(name, Class.new(parent))
        extend_widget(widget_class)
        widget_class.class_eval(&block)
      end
    end

    protected

    def extend_widget(widget_class)
    end

    def parent_widget_class(name)
      return name if name.kind_of? Class
      check_class widget_classes[name] || superclass.try(:parent_widget_class, name)
    end

    private

    def check_class(klass)
      return klass || raise(Hammer::Component::MissingWidgetClass, self)
    end
  end

  # @return [Widget::Component] return instantiated widget or creates one
  def widget
    @widget ||= create_widget
  end

  # @return [String] html
  def to_html
    widget.to_html
  end

  # @return [Class] which is used to insatiate widget
  def widget_class
    case @widget_class
    when Symbol then self.class.widget_class @widget_class
    when Class then @widget_class
    when nil then self.class.widget_class
    else raise ArgumentError
    end
  end

  protected

  # default behavior, can by overwritten
  # @return [Hammer::Widget::Base]
  def create_widget
    widget_class.new(widget_assigns)
  end

  # always pass component to widget, can be extended by overwritten
  def widget_assigns
    {:component => self}
  end

end
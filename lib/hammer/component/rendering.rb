module Hammer::Component::Rendering

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      needs :widget_class => nil
    end
  end

  module ClassMethods
    # @return [Hash{Symbol => Class}] defined widget classes
    def widget_classes
      @widget_classes ||= {}
    end

    # @param [Symbol] name of a widget class
    # @return [Class] widget class by +name+
    def widget_class(name = :Widget)
      check_class widget_classes[name] || parent_widget_class(name)
    end

    # defines widget and executes {#extend_widget} for hooks
    # @param [Symbol] name of a new widget class. If :quicly is passed defines widget quickly which means that
    # block is used to define #content not class
    # @param [Symbol, Class] parent class of new widget class. Symbol is used to find widget class with same name
    # in parent components. Class is used directly. see {#parent_widget_class}
    # @yield block which is evaluated inside new widget class or #contet if :quicly is used
    # @example widget with name Header
    #   define_widget :Header do
    #     wrap_in :h1
    #     def content
    #       text "A header"
    #     end
    #   end
    # @example quickly defined widget with default name Widget
    #   define_widget :quickly do
    #     def content
    #       h1 "A header"
    #     end
    #   end
    def define_widget(name = :Widget, parent = nil, &block)
      if name == :quickly
        define_widget { define_method :content, &block }
      else
        parent = parent_widget_class(parent || name)
        widget_classes[name] = widget_class = const_set(name, Class.new(parent))
        extend_widget(widget_class)
        widget_class.class_eval(&block)
      end
    end

    protected

    # hook for modules included into component, for example Draggable, Droppable
    # @param [Class] widget_class
    def extend_widget(widget_class)
    end

    # @return [Class] widget class for given +name+
    # @param [Symbol] name
    # @see #define_widget
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

  # @return [String] rendered html
  # @param [Hash] options
  def to_html(options = {})
    widget.to_html(options)
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
    { :component => self, :root_widget => true }
  end

end
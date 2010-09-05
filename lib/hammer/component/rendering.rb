module Hammer::Component::Rendering

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      needs :widget_class => nil
    end
  end

  module ClassMethods
    # @return [Hash{Symbol => Class}] defined widget classes
    def widget_classes(inherited = true)
      self.constants(inherited).inject({}) do |hash, const|
        if (klass = const_get(const)) < Hammer::Widget::Base
          hash[const] = klass
        end
        hash
      end
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
    def define_widget(name = :Widget, parent = nil, &block) # TODO remove method
      Hammer.logger.warn 'define_widget is deprecated'
      if name == :quickly
        define_widget { define_method :content, &block }
      else
        parent = parent_widget_class(parent || name)
        widget_class = const_set(name, Class.new(parent))
        # extend_widget(widget_class)
        widget_class.class_eval(&block)
      end
    end

    def extend_widgets
      widget_classes(false).values.each do |widget_class|
        extend_widget_by.each do |a_module|
          unless widget_class.include? a_module
            widget_class.send :include, a_module
          end
        end
      end
    end

    def inherited(klass)
      super
      Hammer.after_load { klass.extend_widgets }
    end

    protected

    # hook for modules included into component, for example Draggable, Droppable. Do not use super.
    # @return [Array<Module>] array of modules used to include to widget classes
    def extend_widget_by
      []
    end

    # @return [Class] widget class for given +name+
    # @param [Symbol] name
    # @see #define_widget
    def parent_widget_class(name)
      return name if name.kind_of? Class
      check_class widget_classes[name] || begin
        superclass.parent_widget_class name if superclass.respond_to? :parent_widget_class
      end
    end

    private

    # raise error if klass is missing
    def check_class(klass)
      return klass || raise(Hammer::Component::MissingWidgetClass, self.to_s)
    end
  end

  # @return [Widget::Component] return instantiated widget or creates one
  def widget
    @widget ||= create_widget
  end

  # @return [String] rendered html
  def to_html
    if changed? || !@_html
      delete_old_actions
      @_html = widget.to_html
      reset_change!
    end
    @_html
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

  # @return [Array<Hammer::Component::Base>] of children components
  def children
    to_html if changed?
    _children
  end

  # @private
  # method used to actualize children during rendering from widget
  def _children
    @_children ||= []
  end

  # @return [Array<Hammer::Component::Base>] all children, self included
  def all_children
    children.inject([self]) {|arr, child| arr + child.all_children }
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

  private

  def delete_old_actions
    context.actions.delete_if {|id, action| action.component == self } # FIXME maybe slow
  end
  

end

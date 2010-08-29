module Hammer::Component

  # include to {Hammer::Component::Base} for enable draggable
  module Draggable
    def self.included(base)
      base.extend ClassMethods
      base.class_inheritable_hash :_draggable, :instance_writer => false, :instance_reader => false
    end

    module ClassMethods
      # @param [Hash] options for RightJS
      def draggable(options)
        self._draggable = options
      end

      protected

      def extend_widget(widget_class)
        super
        widget_class.send :include, Widget unless widget_class.include? Widget
      end
    end

    module Widget
      def wrapper_options
        super.merge :rel => 'draggable', :'data-draggable-options' => component.class._draggable.to_json
      end
    end  
  end

  # include to {Hammer::Component::Base} for enable droppable
  module Droppable
    def self.included(base)
      base.extend ClassMethods
      base.class_inheritable_accessor :_droppable, :instance_writer => false, :instance_reader => false
    end

    module ClassMethods
      # @param [Hash] options for RightJS
      # @option options [Proc] :onDrop action which will be called on drop. Block gets dropped component as a parameter.
      # @example
      #  droppable :accept => '.person-widget', :onDrop => lambda {|person| @people << person; change! }
      def droppable(options)
        self._droppable = options
      end

      protected

      def extend_widget(widget_class)
        super
        widget_class.send :include, Widget unless widget_class.include? Widget
      end
    end

    private

    module Widget
      def wrapper_options
        options = component.class._droppable.clone
        options[:onDrop] = Hammer::JSString.new("function(draggable) { new Hammer.Message()." +
              "setAction(\"#{register_action &component.class._droppable[:onDrop]}\", " +
              "draggable.element.component().id).send() }")
        super.merge :'data-droppable-options' => options.to_json, :rel => 'droppable'
      end
    end

  end
end
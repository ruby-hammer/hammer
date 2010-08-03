module Hammer::Component

  module Draggable
    def self.included(base)
      base.extend ClassMethods
      base.class_inheritable_hash :draggable_options, :instance_writer => false
    end

    module ClassMethods
      def draggable(options)
        self.draggable_options = options
      end

      protected

      def extend_widget(widget_class)
        super
        widget_class.send :include, Widget
      end
    end

    def draggable_js
      @draggable_js ||= Hammer::JQuery.generate(:component => self) do
        jQuery(this).draggable(@component.draggable_options)
      end
    end

    module Widget
      def wrapper_options
        super.merge :'data-js' => component.draggable_js
      end
    end
  
  end

  module Droppable
    def self.included(base)
      base.extend ClassMethods
      base.class_inheritable_accessor :droppable_options, :instance_writer => false
    end

    module ClassMethods
      def droppable(options)
        self.droppable_options = options
      end

      protected

      def extend_widget(widget_class)
        super
        widget_class.send :include, Widget
      end
    end

    EVENTS = [:drop]

    def droppable_js
      options = prepare_options(droppable_options)      
      Hammer::JQuery.generate do
        jQuery(this).droppable(options)
      end
    end

    private

    def prepare_options(options)
      options = options.clone
      EVENTS.each do |event_name|
        if options[event_name]
          action_id = register_action &options[event_name]
          options[event_name] = Hammer::JQuery.generate do
            function(event, ui) do
              console.debug(event);
              console.debug(ui);
              console.debug(jQuery(ui.helper).hammer.componentId!);
              jQuery!.hammer.action(action_id, jQuery(ui.helper).hammer.componentId!).hammer.send!
            end
          end
        end
      end
      options
    end

    module Widget
      def wrapper_options
        super.merge :'data-js' => component.droppable_js
      end
    end

  end
end
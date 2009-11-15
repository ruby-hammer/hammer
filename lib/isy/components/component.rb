module Isy
  module Components
    class Component

      attr_reader :parent, :context, :children

      def initialize(parent, context)
#        case
#        when parent_or_layout.kind_of?(Component) then @parent = parent_or_layout
#        when parent_or_layout < Isy::Widgets::Layout then @layout = parent_or_layout
#        else raise
#        end
        @children = []
        @parent, @context = parent, context
        initial_state
      end

      def new_component(klass, *args, &block)
        @children << begin
          component = klass.new(self, context, *args, &block)
        end
        component
      end

      def widget
        @widget ||= self.class.widget_class.new(*widget_args)
      end

      class_inheritable_accessor :widget_class, :instance_writer => false, :instance_reader => false
      self.widget_class = Isy::Widgets::ComponentInspector

      def to_s
        (root? ? layout : widget).to_s
      end

      def root?
        parent == nil
      end

      class_inheritable_accessor :layout_class, :instance_writer => false, :instance_reader => false

      def layout
        raise RuntimeError, 'i am not root' unless root?
        @layout ||= layout_class.new(self)
      end

      protected

      def initial_state
      end

      def widget_class
        self.class.widget_class
      end

      def widget_args
        [self]
      end


      #      def initialize(app_context)
      #        @app_context = app_context
      #      end
      #
      #      attr_accessor :app_context
      #
      #      def a(action_block, *args, &block)
      #        uuid = register_action(action_block)
      #
      #        url = { :href => "/do-action/#{uuid}" }
      #        if args.last.is_a?(Hash)
      #          args.last.merge url
      #        else
      #          args.push url
      #        end
      #
      #        super(*args, &block)
      #      end
      #
      #      def app_context
      #        @app_context ||= parent.app_context
      #      end
      #
      #      private
      #
      #      def register_action(block)
      #        app_context.register_action(self, &block)
      #      end
    end
  end
end
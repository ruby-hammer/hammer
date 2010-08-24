module Chat
  module Widget
    module InputBluePrint
      def self.included(base)
        base.after_initialize { @label_options.merge! :class => %w[span-3 inline] }
        base.css do
          div { height '36px' }
        end
      end

      def field
        div :class => %w{span-21 last} do
          super
        end
      end
    end

    [:Field, :Select, :Password, :Textarea].each do |klass|
      const_set(klass, Class.new(Hammer::Widget::Form.const_get(klass))).class_eval do
        include InputBluePrint
      end
    end

    Hidden = Hammer::Widget::Form::Hidden

    class Textarea
      css do
        div { height '90px' }
        textarea { height '66px' }
      end
    end
  end
end
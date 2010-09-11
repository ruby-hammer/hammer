module Hammer::Component::Developer::Inspection
  class Abstract < Hammer::Component::Base

    needs :obj, :label => nil
    attr_reader :obj, :label

    class Widget < widget_class :Widget
      def component_label
        component.label ? "#{component.label}: " : ''
      end
    end
  end
end


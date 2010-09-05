module Hammer::Component::Developer::Inspection
  class Simple < Abstract
    class Widget < widget_class :Widget
      def content
        text component_label + obj.inspect
      end
    end
  end

  class String < Simple; end
  class Symbol < Simple; end
  class Numeric < Simple; end
end

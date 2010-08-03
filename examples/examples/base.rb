# encoding: UTF-8
module Examples
  class Base < Hammer::Component::Base

    attr_reader :example

    define_widget do
      def content
        strong 'Examples:'
        ul do
          li { link_to("Counters").action { @example = Examples::Counters::Base.new } }
          li { link_to("#ask").action { @example = Examples::Ask::Base.new } }
          li do
            link_to("Form").action do
              @example = Examples::Form::Base.new \
                  :record => Struct.new("Data", :name, :sex, :password, :hidden, :description).new
            end
          end
          li { link_to("Drag").action { @example = Examples::Dragg::Base.new } }
          li { link_to('none').action { @example = nil } }
        end
        hr

        render example if example
      end
    end

  end
end

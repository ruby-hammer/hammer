# encoding: UTF-8
module Examples
  class Counter < Hammer::Component::Base

    attr_reader :counter
    needs :counter => 0

    define_widget do
      wrap_in(:div)

      def content
        h3 'Counter'
        p do
          text("Value is #{counter} ")
          link_to('Increase').action { @counter += 1 }
          link_to('Decrease').action { @counter -= 1 }
          actions
        end
      end

      def actions
      end
    end

  end
end

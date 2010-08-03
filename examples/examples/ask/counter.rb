# encoding: UTF-8
module Examples
  module Ask
    class Counter < Examples::Counter

      define_widget do

        # adds links to answer the number (counter) or
        # to answer nothing.
        # Everything else is as we need.
        def actions
          link_to('Add number').action { answer!(counter) }
          link_to('Cancel').action { answer! }
        end
      end
    end

  end
end

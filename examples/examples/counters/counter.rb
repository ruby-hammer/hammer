# encoding: UTF-8

module Examples
  module Counters
    class Counter < Examples::Counter

      # we need to store @counters_collection to know where to delete itself
      needs :collection
      attr_reader :collection

      define_widget do
        # here we overwrite actions and to add Remove link
        def actions
          link_to('Remove').action { @collection.remove(self) }
        end
      end
    end
  end
end

# encoding: UTF-8
module Examples
  module Counters
    class Base < Hammer::Component::Base

      attr_reader :counters
      alias_method :collection, :counters

      # defines the state after new instance is created
      after_initialize { @counters = []; add }

      # adds new counter
      def add
        counters << Examples::Counters::Counter.new(:collection => self)
      end

      # removes a +counter+
      def remove(counter)
        counters.delete(counter)
      end

      define_widget :Widget, Hammer::Widget::Collection do
        def after
          link_to('Add counter').action { add }
        end
      end

    end
  end
end

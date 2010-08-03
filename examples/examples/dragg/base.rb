module Examples
  module Dragg
    class Base < Hammer::Component::Base

      attr_reader :draggables, :droppable
      after_initialize do
        @draggables = Array.new(3) {|i| Draggable.new(:number => i) }
        @droppable = Droppable.new
      end

      define_widget :quickly do
        h3 'Drag'

        draggables.each {|d| render d }
        render droppable
      end
    end

    class Draggable < Hammer::Component::Base

      include Hammer::Component::Draggable
      draggable :revert => true, :helper => 'clone'
      needs :number
      attr_reader :number 

      define_widget do
        def content
          strong "Dragable #{number}"
        end
      end

    end

    class Droppable < Hammer::Component::Base
      include Hammer::Component::Droppable
      droppable :drop => lambda { @numbers << arg }
      
      attr_reader :numbers
      after_initialize { @numbers = [] }

      define_widget :quickly do
        strong 'Drop'
        p @numbers.inspect
      end
    end
  end
end

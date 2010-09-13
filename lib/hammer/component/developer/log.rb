# encoding: UTF-8

module Hammer::Component::Developer

  class Entry < Hammer::Component::Base
    attr_reader :message
    needs :message

    class Widget < widget_class :Widget
      wrap_in :code
      css do
        this! { display :block }
      end

      def content
        text message
      end
    end
  end

  class Log < Hammer::Component::Base

    attr_reader :messages

    after_initialize do
      @messages = []
      @limit = 200

      # observe log :message event
      Hammer.logger.add_observer(:message, self, :new_message)
    end

    def new_message(message)
      Hammer.logger.silence(5) do
        add_message(message)
      end
    end

    private

    changing do
      def add_message(message)
        @messages.unshift Entry.new :message => message
        @messages.pop if @messages.size > @limit
      end
    end

    class Widget < widget_class :Widget
      def content
        h3 'Log'
        p "objects observing: #{Hammer.logger.count_observers(:message)}"
        component.messages.each do |message|
          render message
        end
      end
    end
  end
end

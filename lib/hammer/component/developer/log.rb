# encoding: UTF-8

module Hammer::Component::Developer

  class Entry < Hammer::Component::Base
    attr_reader :message
    needs :message

    define_widget do
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
    children :messages

    after_initialize do
      @messages = []
      @limit = 200

      # observe log :message event
      Hammer.logger.add_observer(:message, self, :new_message)

      # listen context for :drop event then delete observer to collect by GC
      # TODO add weak reference to allow collect sooner
      context.add_observer(:drop, self) { Hammer.logger.delete_observer :message, self }
    end

    def new_message(message)
      Hammer.logger.silence(5) do
        add_message(message)
        context.update.send!
      end
    end

    private

    changing do
      def add_message(message)
        @messages.unshift Entry.new :message => message
        @messages.pop if @messages.size > @limit
      end
    end

    define_widget :quickly do
      h3 'Log'
      p "objects observing: #{Hammer.logger.count_observers(:message)}"
      component.messages.each do |message|
        render message
      end
    end
  end
end

module Chat
  class Room < Hammer::Component::Base

    needs :room, :user
    attr_reader :room, :user, :message_form, :messages
    changing { attr_writer :message_form }
    children :message_form, :messages

    after_initialize do
      ask_message
      @messages = []
      room.messages.each {|m| add_message(m) }
      room.add_observer(:new, self, :new_message)
      room.add_observer(:deleted, self, :deleted_message)
      context.add_observer(:drop, self, :context_dropped)
    end

    def leave!
      room.delete_observer :new, self
      room.delete_observer :deleted, self
      context.delete_observer :drop, self
    end

    def new_message(message)
      add_message message
      context.update.send!
    end

    def deleted_message(message)
      remove_message(message)
    end

    def context_dropped(context)
      leave!
    end

    private

    changing do
      def add_message(message)
        @messages.unshift Message.new :message => message
      end

      def remove_message(message)
        @messages.delete @messages.reverse.find {|m| m.message == message }
      end
    end

    def ask_message
      self.message_form = ask Chat::MessageForm.new(:record => Chat::Model::Message.new(user)) do |message|
        room.add_message message
        ask_message
      end
    end

    define_widget :quickly do
      h2 room.name
      render message_form
      messages.each {|m| render m }
    end
  end
end
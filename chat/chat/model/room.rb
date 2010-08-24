module Chat
  module Model
    class Room
      include Hammer::Core::Observable
      observable_events :new, :deleted

      attr_reader  :messages
      attr_accessor :name
      def initialize(name = nil)
        @name = name
        @messages = []
      end

      def valid?
        @name.present?
      end

      def add_message(message)
        @messages.push message
        notify_observers(:deleted, @messages.shift) if @messages.size > 50
        notify_observers(:new, message)
      end

      def last_update
        @messages.first.try(:time) || Time.now
      end

    end
  end
end

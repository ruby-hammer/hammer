module Chat::Model
  class Rooms
    include Singleton
    include Hammer::Core::Observable
    observable_events :new, :deleted

    attr_reader :rooms
    def initialize
      @rooms = []
    end

    def add_room(room)
      @rooms << room
      notify_observers(:new, room)
    end

    def delete_room(room)
      @rooms.delete room
      notify_observers(:deleted, room)
    end

    EM.schedule do
      EventMachine::add_periodic_timer 5 do
        instance.rooms.each do |room|
          instance.delete_room room if Time.now - room.last_update > 60*60
        end
      end
    end

  end
end
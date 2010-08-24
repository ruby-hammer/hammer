module Chat
  class Rooms < Hammer::Component::Base

    attr_reader :room, :user, :room_form
    changing { attr_writer :room_form, :room  }
    children :room, :room_form

    after_initialize do
      pass_on ask(Login.new(:record => Model::User.new)) { |user|
        @user = user
        File.open('users.log', 'a') { |f| f.write "#{@user.nick}\t#{@user.email}\n"  }
        retake_control!

        Chat::Model::Rooms.instance.add_observer(:new, self, :rooms_changed)
        Chat::Model::Rooms.instance.add_observer(:deleted, self, :rooms_changed)
        context.add_observer(:drop, self, :context_dropped)
      }
    end

    def rooms_changed(room)
      change!
      context.update.send!
    end

    def context_dropped(context)
      Chat::Model::Rooms.instance.delete_observer :new, self
      Chat::Model::Rooms.instance.delete_observer :deleted, self
      context.delete_observer :drop, self
    end

    define_widget do
      wrap_in :div

      def wrapper_classes
        super << 'container'# << 'showgrid'
      end

      css do
        a { padding '0 0.2em' }
      end

      def content

        h1 "Chat rooms"

        Model::Rooms.instance.rooms.each do |r|
          link_to("#{r.name}").action do
            self.room.try :leave!
            self.room = Chat::Room.new :room => r, :user => user
          end
        end

        unless room_form
          link_to('new room').action do
            self.room_form = ask Chat::RoomForm.new(:record => Chat::Model::Room.new) do |room|
              Chat::Model::Rooms.instance.add_room(room) if room
              self.room_form = nil
            end
          end
        else
          render room_form
        end

        render room if room
      end
    end

  end
end
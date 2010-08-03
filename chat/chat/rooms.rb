module Chat
  class Rooms < Hammer::Component::Base

    attr_reader :room, :user, :room_form

    after_initialize do
      pass_on ask(Login.new(:record => Model::User.new)) { |user|
        @user = user
        File.open('users.log', 'a') { |f| f.write "#{@user.nick}\t#{@user.email}\n"  }
        retake_control!
      }
    end

    define_widget do
      wrap_in :div

      def content

        h1 "Chat rooms"

        Model::Room.rooms.each do |r|
          link_to("#{r.name} (#{r.messages.size})").action do
            @room.try :leave!
            @room = Chat::Room.new :room => r, :user => user
          end
        end

        unless room_form
          link_to('new room').action do
            @room_form = ask Chat::RoomForm.new(:record => Chat::Model::Room.new) do |room|
              Chat::Model::Room.rooms << room if room
              @room_form = nil
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
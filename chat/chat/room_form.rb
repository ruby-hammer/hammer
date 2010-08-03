module Chat
  class RoomForm < Hammer::Component::Base

    include Hammer::Component::Form
    alias_method(:room, :record)

    define_widget do
      wrap_in(:span)
      def content
        widget Hammer::Widget::Form::Field, :value => :name, :options =>
            { :class => %w[ui-widget-content ui-corner-all] }
        submit("Add").update { answer!(room) if room.valid? }
        link_to("Cancel").action { answer!(nil) }
      end
    end

  end
end
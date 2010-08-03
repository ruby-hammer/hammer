module Chat
  class MessageForm < Hammer::Component::Base

    include Hammer::Component::Form
    alias_method(:message, :record)

    define_widget do
      wrap_in :div

      def content
        widget Hammer::Widget::Form::Textarea, :value => :text,
            :options => { :rows => 2, :class => %w[ui-widget-content ui-corner-all] }
        submit("Send").update do
          if message.valid?
            message.time!
            answer!(message)
          end
        end
      end
    end

  end
end
module Chat
  class Message < Hammer::Component::Base
    needs :message
    attr_reader :message

    define_widget do
      require 'gravatarify'
      include Gravatarify::Helper

      css do
        class!(:user) { text_align 'center' }
        this! {
          background_color '#EEE'
          margin_bottom '18px'
        }
      end

      def wrapper_classes
        super << 'span-24'
      end

      def content
        div :class => %w{span-1} do
          img :src => gravatar_url(message.user.email, :size => 38, :default => :wavatar), :alt => 'avatar'
        end

        div :class => %w{span-2 user} do
          strong "#{message.user}"
          br
          text message.time.strftime('%H:%M:%S')
        end

        div :class => %w{span-21 last} do
          text "#{message.text}"
        end
      end
    end
  end
end
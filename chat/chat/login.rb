# encoding: UTF-8

module Chat
  class Login < Hammer::Component::Base

    include Hammer::Component::Form
    alias_method(:user, :record)

    define_widget do
      wrap_in :div

      def content
        p do
          h1 "Log in", :class => %w[ui-widget]
          widget Hammer::Widget::Form::Field, :value => :nick, :label => 'Nick:',
              :options => { :class => %w[ui-widget-content ui-corner-all] }
          widget Hammer::Widget::Form::Field, :value => :email, :label => 'Gravatar email:',
              :options => { :class => %w[ui-widget-content ui-corner-all] }
          submit("Log in").update { answer!(user) if user.valid? }
        end
      end
    end

  end
end
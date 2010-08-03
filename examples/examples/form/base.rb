# encoding: UTF-8

module Examples
  module Form
    class Base < Hammer::Component::Base
      include Hammer::Component::Form

      attr_reader :counter
      after_initialize { @counter = 0 }

      define_widget do
        wrap_in :div

        def content
          widget Hammer::Widget::Form::Field, :value => :name, :label => 'Name:'
          widget Hammer::Widget::Form::Hidden, :value => :hidden, :options => {:value => 'hid'}
          widget Hammer::Widget::Form::Password, :value => :password, :label => 'Password:'
          widget Hammer::Widget::Form::Select, :value => :sex, :label => 'Sex:',
              :select_options => [nil, 'male', 'female']
          widget Hammer::Widget::Form::Textarea, :value => :description, :label => 'Description:'

          submit("Send for the #{counter}th time").update { @counter += 1 }

          h4 'Values:'
          ul do
            record.members.each do |key|
              li "#{key}: #{value(key).inspect}"
            end
          end

          render sub if sub

        end
      end

    end
  end
end

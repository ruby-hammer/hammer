# encoding: UTF-8

module Examples
  module Form
    class Base < Hammer::Component::Base
      include Hammer::Component::Form

      attr_reader :counter
      after_initialize { @counter = 0 }

      define_widget do
        def wrapper_classes
          super << 'form'
        end

        def content
          render Examples::Widget::Field.new :component => component, :value => :name, :label => 'Name:'
          render Examples::Widget::Hidden.new :component => component, :value => :hidden
          render Examples::Widget::Password.new :component => component, :value => :password, :label => 'Password:'
          render Examples::Widget::Select.new :component => component, :value => :sex, :label => 'Sex:',
              :select_options => [nil, 'male', 'female']
          render Examples::Widget::Textarea.new :component => component, :value => :description,
              :label => 'Description:'

          div :class => %w{span-21 prepend-3 last}, :style => 'height: 36px;' do
            submit("Send for the #{counter}th time", :class => %w{clear}).update { @counter += 1 }
          end

          hr
          strong 'Values:'
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

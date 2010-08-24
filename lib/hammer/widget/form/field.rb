module Hammer::Widget::Form
  class Field < Abstract
    def type
      :text
    end

    def field
      input({ :name => @value, :value => value(@value), :type => type, :id => @label_id }.merge(@options))
    end
  end
end

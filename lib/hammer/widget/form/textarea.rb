module Hammer::Widget::Form
  class Textarea < Abstract
    def field
      textarea(value(@value), { :type => @type, :name => @value, :id => @label_id }.merge(@options))
    end
  end
end

module Hammer::Widget
  def self.all
    Hammer::Widget::Base.descendants
  end
end
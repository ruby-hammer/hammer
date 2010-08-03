module Hammer::Widget::JQuery
  def self.included(base)
    base.extend self
  end

  def jquery(&block)
    Hammer::JQuery.generate(:widget => self, &block).to_js
  end
end

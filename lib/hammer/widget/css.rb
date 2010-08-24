module Hammer::Widget::CSS
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def css(&block)
      css_builders << Hammer::CSS::Builder.new(&block)
    end

    def css_builders
      @css_builders ||= []
    end
  end

  def self.css
    Hammer::Widget.all.map do |widget|
      widget.css_builders.map do |builder|
        builder.to_css [widget, *widget.descendants].map {|klass| klass.css_class }
      end
    end.flatten.join
  end
end

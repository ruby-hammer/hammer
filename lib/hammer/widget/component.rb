# encoding: UTF-8

module Hammer::Widget::Component

  def self.included(base)
    base.class_eval do
      needs :component
      attr_reader :component
    end
  end

  # automatically passes :component assign to child widgets
  def widget(target, assigns = {}, options = {}, &block)
    assigns.merge!(:component => @component) {|_,old,_| old } if target.is_a? Class
    super target, assigns, options, &block
  end

  def a(*args, &block)
    super *args.push(args.extract_options!.merge(:href => '#')), &block
  end

  # calls missing methods on component
  def method_missing(method, *args, &block)
    if component.respond_to?(method)
      component.__send__ method, *args, &block
    else
      super
    end
  end

  def respond_to?(symbol, include_private = false)
    component.respond_to?(symbol) || super
  end

  def render(obj)
    if obj.kind_of?(Hammer::Component::Base)
      render_component(obj)
    else super
    end
  end

  private

  # renders replacer in place of component when rendering update
  def render_component(component)
    unless render_options[:update]
      widget component.widget
    else
      div :'data-component-replace' => component.object_id
    end
  end

end
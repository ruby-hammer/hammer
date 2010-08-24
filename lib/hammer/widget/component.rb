# encoding: UTF-8

module Hammer::Widget::Component

  def self.included(base)
    base.class_eval do
      needs :component, :root_widget => false
      attr_reader :component
      wrap_in :div
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

  def root_widget?
    @root_widget
  end

  def wrapper_options
    return super unless root_widget?
    super.merge :id => component.object_id
  end

  def wrapper_classes
    return super unless root_widget?
    super << 'component'
  end
end
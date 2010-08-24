module Hammer::Widget::Wrapping

  def self.included(base)
    base.class_inheritable_accessor :_wrapper, :instance_reader => false, :instance_writer => false
    base.extend ClassMethods
  end

  module ClassMethods
    # @param [Symbol] element which will by used to wrap widget
    def wrap_in(element)
      self._wrapper = element
    end

    # @return [Symbol] element which will by used to wrap widget
    def wrapped_in
      self._wrapper
    end

    # @return [String] class name transformed into CSS class, used by #content_with_wrapper
    def css_class
      @css_class ||= self.to_s.underscore.gsub '/', '-'
    end
  end

  # renders wrapper with content in +block+
  # @yield block content
  def wrapper(&block)
    if self.class.wrapped_in
      send self.class.wrapped_in, wrapper_options, &block
    else
      raise "no wrapper for #{self.class}"
    end
  end

  protected

  # Wraps widget with element set by .wrap_in. Method is called automatically use #content.
  def call_content_method
    wrapper { super }
  end

  # @return [Hash] options passed to wrapping element, intended for overwriting
  def wrapper_options
    { :class => wrapper_classes }
  end

  # @return [Array<String,Symbol>] wrapper's css classes
  def wrapper_classes
    [self.class.css_class]
  end
end
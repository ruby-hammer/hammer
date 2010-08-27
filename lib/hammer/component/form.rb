module Hammer::Component::Form

  def self.included(base)
    base.extend ClassMethods
    base.class_inheritable_accessor :_on_submit, :instance_reader => false, :instance_writer => false
    base.class_eval do
      needs :record
      attr_reader :record
      changing :set_value
    end
  end

  module ClassMethods

    def on_submit(&block)
      self._on_submit = block
    end

    def on_submit?
      !!self._on_submit
    end

    protected

    def extend_widget(widget_class)
      super
      widget_class.send :include, Widget unless widget_class.include? Widget
    end

  end

  module Widget
    def wrapper(&block)
      options = {:action => '#'}
      options[:'data-action-id'] = register_action(&component.class._on_submit) if component.class.on_submit?
      super do
        form options, &block
      end
    end
  end

  # values from form's tags are stored here. They are automatically updated when :form callback is triggered
  # @return [Object] value for +key+
  # @param [Symbol] key of a value
  def value(key = :value)
    @record.send key
  end

  # @overload set_value(key, value)
  #   Sets a value on key
  #   @param [Symbol] key
  #   @param [Object] value
  # @overload set(value)
  #   Sets a value on the default key :value
  #   @param [Object] value describe value param
  def set_value(*args)
    key, value = args.pop 2
    unless value
      value, key = key, :value
    end
    @record.send "#{key}=", value
  end
end

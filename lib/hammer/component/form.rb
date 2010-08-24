module Hammer::Component::Form

  def self.included(base)
    base.class_eval do
      needs :record
      attr_reader :record
      changing :set_value
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

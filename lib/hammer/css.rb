module Hammer::CSS

  # @param [Array<String>,String] space_classes css classes to limit space where generated css will have effect
  # @yield block generating css, evaluated with instance_eval
  # @return [String] generated css with +block+ limited to +space_classes+
  def self.generate(space_classes = nil, &block)
    Builder.new(&block).to_css(space_classes)
  end

  # can be used to delay css generating, see {#to_s}
  class Builder
    attr_reader :selectors
    def initialize(&block)
      @selectors = []
      instance_eval &block
    end

    def id!(name, arg = nil, &block)
      Selector.id!(self, name, arg, &block)
    end

    def class!(name, arg = nil, &block)
      Selector.class!(self, name, arg, &block)
    end

    def this!(arg = nil, &block)
      Selector.new(self, '*', arg, &block)
    end

    def method_missing(name, arg = nil, &block)
      Selector.new(self, name, arg, &block)
    end

    # @param [Array<String>,String] space_classes css classes to limit space where generated css will have effect
    # @return [String] generated css with +block+ limited to +space_classes+
    def to_s(space_classes = nil)
      selectors.inject("") do |str, selector|
        str << selector.to_s(space_classes)
      end
    end

    alias_method :to_css, :to_s
  end

  class Selector
    def self.id!(builder, name, arg = nil, &block)
      new(builder, "##{name}", arg, &block)
    end

    def self.class!(builder, name, arg = nil, &block)
      new(builder, ".#{name}", arg, &block)
    end

    attr_reader :selector, :properties
    def initialize(builder, selector, arg = nil, properties = nil, &block)
      selector = selector.to_s
      selector += if arg.kind_of?(Hash)
        if arg[:id]
          "##{arg[:id]}"
        elsif arg[:class]
          ".#{arg[:class]}"
        else
          raise ArgumentError
        end
      elsif arg.kind_of?(Symbol)
        ":#{arg}"
      elsif arg.nil?
        ''
      elsif arg.kind_of?(String)
        arg
      else
        raise ArgumentError
      end
      selector = "* #{selector}" unless selector =~ /^\*/
      @builder, @selector = builder, selector
      @builder.selectors << self
      @properties = properties || block && Properties.new(&block)
    end

    OPERATORS = {
      '+' => '+',
      '~' => '~',
      '|' => ', ',
      '>' => '>',
      '>>' => ' '
    }

    OPERATORS.each do |ruby, css|
      define_method(ruby) {|selector| join(css, selector) }
    end

    def to_s(space_classes = nil)
      selector = if space_classes
        apply_space_classes(space_classes)
      else
        @selector
      end
      "#{selector} " + if properties
        "{\n#{properties.to_s}}"
      else
        "{}"
      end + "\n\n"
    end

    def merged!
      @merged = true
    end

    def merged?
      @merged
    end

    private

    def apply_space_classes(space_classes)
      [*space_classes].map do |space_class|
        @selector.split(/, /).map do |part|
          part.gsub '*', ".#{space_class}"
        end
      end.flatten.join(', ')
    end

    def join(with, selector)
      raise if self.properties && selector.properties
      @builder.selectors.delete selector
      i = @builder.selectors.index self
      self.class.new(@builder, self.selector + with + selector.selector[(with == ', ' ?0:2)..-1], nil,
        @properties || selector.properties)
      @builder.selectors[i] = @builder.selectors.pop # move from end to original position
    end
  end

  Property = Struct.new :name, :values

  class Properties < BasicObject
    def initialize(&block)
      @properties = []
      instance_eval &block
    end

    def method_missing(property, *values)
      @properties << Property.new(property.to_s.gsub(/_/, '-'), values.map(&:to_s))
    end

    def to_s
      @properties.map do |property|
        "  #{property.name}: #{property.values.map(&:to_s).join(' ')};\n"
      end.join
    end
  end

end
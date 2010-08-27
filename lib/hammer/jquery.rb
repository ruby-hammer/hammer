module Hammer::JQuery

  # @return [String] generated js. It doesn't support operators and loops,
  # its goal is to generate function calls.
  # @yield block ruby generating js
  # @example
  #   generate { jquery.jq! } # => "jQuery.jQuery()"
  #   generate { a(1 => "a", :b => [1,2]) # => "a({\"1\":\"a\",\"b\":[1,2]})"
  #   generate { b(a!, a); a.c(b(c)); } # => "b(a(),a);a.c(b(c));"
  #   generate { b(function(b!, :a) {b!.c!} } # => "b(function(b(), "a") {b().c();});"
  #   generate { a :a => function(a) {b.c!} } # => 'a({"a":function(a) {b.c();}});"
  def self.generate(assigns = {}, &block)
    Builder.new(assigns, &block)
  end

  class Abstract
    def _format_args(*args)
      args.map(&:to_json).join ','
    end

    def to_js
      return nil if argument?
      to_s
    end

    def encode_json(encoder)
      argument!
      self.to_s
    end

    def as_json(options = nil)
      self
    end

    def argument?
      @argument
    end

    def argument!
      @argument = true
      self
    end
  end

  class Builder < Abstract
    def initialize(assigns, &block)
      assigns.each {|k,v| instance_variable_set("@#{k}", v) }
      @assigns, @stacks = assigns, []
      instance_eval &block
    end

    def method_missing(method, *args)
      @stacks << stack = MethodStack.new
      stack.send(method, *args)
      stack
    end

    def call(method, *args)
      method_missing(method, *args)
    end

    def function(*args, &block)
      @stacks << function = Function.new(@assigns, *args, &block)
      function
    end
    alias_method(:fn, :function)

    def to_s
      @stacks.map(&:to_js).compact.join(';') << ';'
    end
  end

  class Function < Builder
    def initialize(assigns, *args, &block)
      @args = _format_args(*args)
      super(assigns, &block)
    end

    def to_s
      "function(#{@args}) {#{super}}"
    end
  end

  class MethodStack < Abstract
    def initialize
      @methods = []
    end

    def method_missing(method, *args)
      _method(method, *args)
    end

    def to_s
      @methods.join('.')
    end

    private

    ALIASES = {
      'jquery' => 'jQuery',
      'jq' => 'jQuery',
    }

    def _method(method, *args)
      method.to_s =~ /([\w_$]+)(!|)/
      method = ALIASES[$1] || $1
      if args.blank? && $2.blank?
        @methods << method
      else
        @methods << "#{method}(#{_format_args(*args)})"
      end
      self
    end

  end

end
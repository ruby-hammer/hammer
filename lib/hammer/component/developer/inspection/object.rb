module Hammer::Component::Developer::Inspection
  class Object < Abstract

    needs :packed => true
    attr_reader :components
    children :components

    # @option assigns [String] :label optional description
    # @option assigns [Boolean] :packed inspector is initially packed?
    def initialize(assigns = {})
      super
    end

    after_initialize { packed? ? pack : unpack }

    # @return [Boolean] is inspector packed?
    def packed?
      @packed
    end

    # switches packed state and calls {#pack} or {#unpack} to change the state
    def toggle!
      @packed = !@packed
      packed? ? pack : unpack
    end

    changing :toggle!

    protected

    # unpacks inspector, creates subinspectors for instance variables, constants etc.
    def unpack
      variables = obj.instance_variables.inject({}) {|hash, name| hash[name] = obj.instance_variable_get(name); hash }
      @components = [ inspector(variables, :label => 'Instance variables') ]
    end

    # packs inspector, drops subinspectors
    def pack
      @components = []
    end

    define_widget do
      def content
        packed
        ul { unpacked } unless packed?
      end

      # renders packed form
      def packed
        link_to("#{component_label}#{name}").action { toggle! }
      end

      # renders name of the inspector
      def name
        "##{obj.class}"
      end

      # renders unpacked form
      def unpacked
        li "size #{obj.size}" if obj.respond_to?(:size)
        components.each do |c|
          li { render c }
        end
      end

    end

  end
end

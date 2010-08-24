# encoding: UTF-8

# Abstract class of all widgets
module Hammer::Widget
  class SuperAbstract < Erector::AbstractWidget
    include Erector::HTML
    include Erector::Needs
    #    include Erector::Caching # TODO add if usable
    include Erector::Convenience
    include Erector::AfterInitialize
  end

  class Abstract < SuperAbstract

    # try to obtain widget and render it with Erector::Widget#widget
    # @param [Erector::Widget, #widget] obj to render
    def render(obj)
      widget begin
        if obj.kind_of?(Abstract)
          obj
        elsif obj.respond_to?(:widget)
          obj.widget
        else
          raise ArgumentError, obj.inspect
        end
      end
    end

  end
end


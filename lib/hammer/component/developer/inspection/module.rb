module Hammer::Component::Developer::Inspection

  class Module < Object
    def unpack
      constants = obj.constants.inject({}) {|hash, name| hash[name] = obj.const_get(name); hash }
      super <<
          inspector(constants, :label => 'Constants') <<
          inspector(obj.included_modules, :label => 'Included Modules')
    end

    class Widget < widget_class :Widget
      def name
        obj.to_s
      end
    end

  end
end

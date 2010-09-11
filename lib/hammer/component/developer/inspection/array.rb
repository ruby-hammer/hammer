module Hammer::Component::Developer::Inspection
  class Array < Object
    def unpack
      @components = obj.each_with_index.map do |value, i|
        inspector value, :label => "#{i} "
      end
    end
  end
end

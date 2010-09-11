module Hammer::Component::Developer::Inspection
  class Class < Module
    def unpack
      instances = []
      ObjectSpace.each_object(obj) {|obj| instances << obj }
      super << inspector(obj.superclass, :label => 'superclass') <<
          inspector(instances, :label => 'instances')
    end
  end
end

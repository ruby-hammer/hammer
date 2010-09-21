module Hammer
  module DataMapper
    module StandardEvents
      def self.included(base)
        #        base.send :include, Hammer::Core::Observable unless base < Hammer::Core::Observable
        base.extend Hammer::Core::Observable unless base.singleton_class.include? Hammer::Core::Observable
        base.instance_eval do
          observable_events :created, :destroyed, :edited
        end
        base.class_eval do
          after :save do
            if new?
              self.class.notify_observers(:created, self)
            else
              self.class.notify_observers(:edited, self)
            end
          end

          after :destroy do
            self.class.notify_observers(:destroyed, self)
          end
        end
      end
    end
  end
end
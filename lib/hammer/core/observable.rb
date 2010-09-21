module Hammer::Core::Observable
  def self.included(base)
    base.send :include, Methods
    base.send :include, InstanceMethods
    base.extend Methods
    base.extend ClassMethods
    base.class_inheritable_array :_instance_observable_events, :instance_reader => false, :instance_writer => false
    base.class_inheritable_array :_class_observable_events, :instance_reader => false, :instance_writer => false
  end

  module ClassMethods
    # @return [Array<Symbol>] allowed events
    def instance_observable_events(*events)
      self._instance_observable_events = events
    end

    # @return [Array<Symbol>] allowed events
    def class_observable_events(*events)
      self._class_observable_events = events
    end

    def observable_events
      self._class_observable_events
    end
  end

  module InstanceMethods
    def observable_events
      self.class._instance_observable_events
    end
  end

  module Methods
    # adds observer to listening to event
    # @param [Symbol] event to observe
    # @param [Hammer::Component::Base] observer
    # @param [Symbol] method to call on observer
    # @return [Hammer::Component::Base] observer
    def add_observer(event, observer, method = :update, &block)
      check_event(event)
      raise NoMethodError, "observer does not respond to `#{method.to_s}'" unless block || observer.respond_to?(method)
      _observers(event)[observer] = block || method
      observer
    end

    # deletes observer from listening to event
    # @param [Symbol] event to observe
    # @param [Object] observer
    def delete_observer(event, observer)
      check_event(event)
      _observers(event).delete(observer)
    end

    # @param [Symbol] event to observe
    def notify_observers(event, *args)
      check_event(event)
      _observers(event).each do |observer, method|
        if Hammer.get_context == observer.context
          notify_observer(observer, method, *args)
        else
          observer.context.schedule { notify_observer(observer, method, *args) }
        end
      end
    end

    def count_observers(event)
      check_event(event)
      _observers(event).size
    end

    def get_observers(event)
      check_event(event)
      _observers(event).keys
    end

    private

    def _observers(event)
      check_event(event)
      @_observers ||= {}
      @_observers[event] ||= Hammer::Weak::Hash[:key].new
    end

    def notify_observer(observer, method, *args)
      if method.is_a?(Symbol)
        observer.send method, *args
      else
        method.call *args
      end
    end

    def check_event(event)
      unless observable_events.include? event
        raise ArgumentError, "event '#{event}' is not included in events' list #{observable_events}"
      end
    end
  end
end

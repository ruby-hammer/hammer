module Hammer::Core::Observable
  def self.included(base)
    base.extend ClassMethods
    base.class_inheritable_array :_observable_events, :instance_reader => false, :instance_writer => false
  end

  module ClassMethods
    # @return [Array<Symbol>] allowed events
    def observable_events(*events)
      self._observable_events = events unless events.blank?
      return _observable_events
    end
  end

  # adds observer to listening to event
  # @param [Symbol] event to observe
  # @param [Hammer::Component::Base] observer
  # @param [Symbol] method to call on observer
  # @return [Hammer::Component::Base] observer
  def add_observer(event, observer, method = :update, &block)
    raise ArgumentError unless self.class.observable_events.include? event
    raise NoMethodError, "observer does not respond to `#{method.to_s}'" unless block || observer.respond_to?(method)
    _observers(event)[observer] = block || method
    observer
  end

  # deletes observer from listening to event
  # @param [Symbol] event to observe
  # @param [Object] observer
  def delete_observer(event, observer)
    _observers(event).delete(observer)
  end

  # @param [Symbol] event to observe
  def notify_observers(event, *args)
    _observers(event).each do |observer, method|
      if Hammer.get_context == observer.context
        notify_observer(observer, method, *args)
      else
        observer.context.schedule { notify_observer(observer, method, *args) }
      end
    end
  end

  def count_observers(event)
    _observers(event).size
  end

  private

  def _observers(event)
    raise ArgumentError unless self.class.observable_events.include? event
    @_observers ||= {}
    @_observers[event] ||= {}
  end

  def notify_observer(observer, method, *args)
    if method.is_a?(Symbol)
      observer.send method, *args
    else
      method.call *args
    end
  end

end

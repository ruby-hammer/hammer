class Hammer::Observer
  module Helper
    def self.included(base)
      aliases base
      super
    end

    def self.extended(base)
      aliases base
      super
    end

    def observer
      @observer ||= Hammer::Observer.new(self, *events)
    end

    private

    def self.aliases(base)
      base.send :alias_method, :observe, :observer
    end
  end

  attr_reader :obj

  def initialize(obj)
    raise ArgumentError, 'obj has to respond to #app' unless obj.respond_to? :app
    @obj         = obj
    @observables = Hammer::Weak::Hash[:key].new
  end

  def fire!(name, observable, *args)
    raise unless obj.respond_to? :context
    if obj.core.current_app == obj.app
      @observables[observable][name].call *args
    else
      obj.context.scheduler.run { @observables[observable][name].call *args }
    end
  end

  def method_missing(name, obj_or_observable, &block)
    observable = if obj_or_observable.is_a? Hammer::Observable
                   obj_or_observable
                 else
                   obj.observable
                 end
    if observable.respond_to? name
      listen name, observable, &block
    else
      super
    end
  end

  private

  def listen(name, observable, &block)
    observable.public_send(name, self)
    @observables[observable]       ||= { }
    @observables[observable][name] = block
  end
end

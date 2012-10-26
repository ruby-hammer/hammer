class Hammer::Observer
  include Hammer::CurrentApp

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
      @observer ||= Hammer::Observer.new(self)
    end

    private

    def self.aliases(base)
      base.send :alias_method, :observe, :observer
      base.send :alias_method, :on, :observer
    end
  end

  attr_reader :obj

  def initialize(obj)
    @obj         = obj
    @observables = Hammer::Weak::Hash[:key].new
  end

  def run(name, observable, *args)
    print "event #{name} in #{observable.obj} for #{obj}"
    if !obj.respond_to?(:app) || current_app == obj.app
      puts " run in #{current_app}"
      @observables[observable][name].call *args
    else
      puts " scheduled in #{obj.app}"
      obj.app.schedule.action { @observables[observable][name].call *args }
    end
  end

  def method_missing(method, *args, &block)
    return super unless args.size == 1

    obj_or_observable = args.first
    if obj_or_observable.is_a? Hammer::Observable
      observable = obj_or_observable
    elsif obj_or_observable.respond_to?(:observable) && obj_or_observable.observable.is_a?(Hammer::Observable)
      observable = obj_or_observable.observable
    else
      return super
    end

    if observable.has_event? method
      listen method, observable, &block
    else
      raise "no event '#{method}' on #{observable.obj}"
    end
  end

  def listen(name, observable, &block)
    observable.add_observer(name, self)
    @observables[observable]       ||= { }
    @observables[observable][name] = block
  end

  def no_more(name, observable)
    observable.remove_observer(name, self)
    @observables[observable].delete name if @observables[observable]
  end
end

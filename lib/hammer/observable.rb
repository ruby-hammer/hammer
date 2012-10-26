class Hammer::Observable

  module Helper
    def self.included(base)
      aliases base
      super
    end

    def self.extended(base)
      aliases base
      super
    end

    def observable
      @observable ||= Hammer::Observable.new(self)
    end

    private

    def self.aliases(base)
      base.send :alias_method, :fire, :observable
    end
  end

  attr_reader :obj

  def initialize(obj)
    @obj       = obj
    @observers = { }
  end

  def events
    @observers.keys
  end

  def events=(events)
    [*events].each { |event| add_event(event) }
  end

  def add_event(event)
    @observers[event.to_sym] = Hammer::Weak::Queue.new
    true
  end

  def remove_event(event)
    !! @observers.delete(event.to_sym)
  end

  def has_event?(event)
    @observers.has_key?(event)
  end

  def fire_event(event, *args)
    @observers[event].each do |observer|
      observer.run(event, self, *args)
    end
  end

  def add_observer(event, observer)
    check_event(event)
    @observers[event].push observer
  end

  def remove_observer(event, observer)
    check_event(event)
    @observers[event].delete observer
  end

  def method_missing(method, *args, &block)
    if has_event? method
      fire_event method, *args
    else
      super
    end
  end

  private

  def check_event(event)
    raise "no event with name '#{event}'" unless has_event? event
  end

end

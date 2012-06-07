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

    def observable(*events)
      if @observable
        @observable.events *events
        @observable
      else
        @observable = Hammer::Observable.new(self, *events)
      end
    end

    private

    def self.aliases(base)
      base.send :alias_method, :fire, :observable
    end
  end

  attr_reader :events, :obj

  def initialize(obj, *events)
    @obj       = obj
    @events    = []
    @observers = Hash.new { |hash, key| hash[key] = Hammer::Weak::Queue.new }
    events(*events)
  end

  def events(*names)
    names.each { |name| add_event(name) } unless names.empty?
    @events
  end

  private

  def fire!(name, *args)
    @observers[name].each do |observer|
      observer.fire!(name, self, *args)
    end
  end

  def listen(name, observer)
    @observers[name].push observer
  end

  def add_event(name)
    name = name.to_sym
    @events << name
    singleton_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{name}!(*args)
        fire!(:#{name}, *args)
      end
      def #{name}(observer)
        listen(:#{name}, observer)
      end
    RUBY
  end

end

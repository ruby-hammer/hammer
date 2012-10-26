module Hammer::Components

  class Counters
    include Hammer::Observable::Helper
    include Hammer::Observer::Helper

    attr_reader :counters, :sum

    def initialize(values)
      observable.events = :changed, :counter_added, :counter_removed
      @counters         = []
      values.each { |v| add v }
    end

    def add(value = 0)
      counters << counter = Counter.new(value)
      on.changed(counter) { |value| update_sum(value) }
      update_sum
      fire.counter_added counter
    end

    def remove(counter)
      counters.delete(counter)
      update_sum
      fire.counter_removed counter
    end

    def up(counter)
      i = counters.index(counter)
      if i == 0
        counters.push counters.shift
      else
        counters.insert i-1, *counters.slice!(i-1, 2).reverse
      end
      fire.changed
    end

    def down(counter)
      i = counters.index(counter)
      if i == counters.size-1
        counters.unshift counters.pop
      else
        counters.insert i, *counters.slice!(i, 2).reverse
      end
      fire.changed
    end

    def update_sum(value = nil)
      if @sum && value
        @sum += value
      else
        @sum = counters.inject(0) { |sum, c| sum + c.value }
      end
      fire.changed
    end

    def size
      @counters.size
    end

    def each
      @counters.each { |c| yield c }
    end

    include Enumerable
  end

  class Counter
    include Hammer::Observable::Helper

    attr_reader :value

    def initialize(value = 0)
      observable.events = :changed
      @value            = value
    end

    def value=(v)
      diff   = v - @value
      @value = v
      fire.changed diff
    end
  end

  COUNTERS = Counters.new [0, 1, 2]

  class CountersComponent < Hammer::Component
    attr_reader :counters, :counter_components

    def initialize(app, options = { })
      super app, options

      @counters           = COUNTERS
      @counter_components = { }

      counters.each { |counter| new_counter counter }

      on.changed(counters) { state.change! }

      on.counter_added(counters) do |counter|
        new_counter counter
        state.change!
      end

      on.counter_removed(counters) do |counter|
        remove_counter counter
        state.change!
      end
    end

    def content(b)
      b.h1 'Counters'
      #b.p do
      #  b.text "container: " + app.context.container.id
      #  b.br
      #  b.text "context: " + app.context.id
      #end
      b.p "sum #{counters.sum} in #{counters.size} counters"
      #b.p counters.map(&:id).join(', ')
      counters.each do |counter|
        b.component counter_components[counter]
      end
      b.p { b.a('Add').action { counters.add } }
    end

    def to_url
      ''
    end

    def from_url(url)
    end

    private

    def new_counter(counter)
      @counter_components[counter] = new CounterComponent, counter
    end

    def remove_counter(counter)
      @counter_components.delete counter
    end
  end

  class CounterComponent < Hammer::Component
    attr_reader :counters, :counter

    def initialize(app, counter, options = { })
      super app, options
      @counter = counter
      on.changed(counter) { state.change! }
    end

    def content(b)
      b.h2 'Counter'
      b.p do
        b.text("Value is #{counter.value} ")
        b.join [lambda { b.a('Increase').action { counter.value += 1 } },
                lambda { b.a('Decrease').action { counter.value -= 1 } },
                lambda { b.a('Remove').action { COUNTERS.remove(counter) } },
                lambda { b.span('Up').action('alternative') { COUNTERS.up(counter) } },
                lambda { b.span('Down').action('alternative') { COUNTERS.down(counter) } }],
               ' '
      end
    end
  end


end

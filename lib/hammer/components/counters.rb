module Hammer::Components

  class Counters < Hammer::Component
    attr_reader :counters

    def initialize(app, options = { })
      @counters = []
      super app, options
    end

    changing do
      # adds new counter
      def add(url = nil)
        counters << new(Counter, self, :url => url)
      end

      # removes a +counter+
      def remove(counter)
        counters.delete(counter)
      end

      def up(counter)
        i = counters.index(counter)
        if i == 0
          counters.push counters.shift
        else
          counters.insert i-1, *counters.slice!(i-1, 2).reverse
        end
      end

      def down(counter)
        i = counters.index(counter)
        if i == counters.size-1
          counters.unshift counters.pop
        else
          counters.insert i, *counters.slice!(i, 2).reverse
        end
      end
    end

    def content(b)
      b.h1 'Counters'
      #b.p do
      #  b.text "container: " + app.context.container.id
      #  b.br
      #  b.text "context: " + app.context.id
      #end
      b.p counters.map(&:id).join(', ')
      counters.each do |counter|
        b.c counter
      end
      b.p { b.a('Add').action { add } }
    end

    def to_url
      "counters:" + counters.map(&:to_url).join(',')
    end

    def from_url(url)
      if url.blank? || url !~ /counters:([-\d,]+)/
        4.times { add }
      else
        $1.split(',').each { |i| add i }
      end
    end
  end

  class Counter < Hammer::Component
    attr_reader :counter, :counters
    changing { attr_writer :counter }

    def initialize(app, counters, options = { })
      @counters = counters
      super app, options
    end

    def content(b)
      b.h2 'Counter'
      b.p do
        b.text("Value is #{counter} ")
        b.join [lambda { b.a('Increase').action { self.counter += 1 } },
                lambda { b.a('Decrease').action { self.counter -= 1 } },
                lambda { b.a('Remove').action { counters.remove(self) } },
                lambda { b.span('Up').action('alternative') { counters.up(self) } },
                lambda { b.span('Down').action('alternative') { counters.down(self) } }],
               ' '
      end
    end

    def to_url
      counter.to_s
    end

    def from_url(url)
      @counter = url.to_i
    end
  end


end

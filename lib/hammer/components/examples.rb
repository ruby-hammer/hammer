module Hammer::Components
  class Examples < Hammer::Component

    attr_reader :kind, :example

    EXAMPLES = { 'blank'       => Blank,
                 'counters'    => CountersComponent,
                 'calculator'  => Calculator,
                 'inspections' => Inspections::Example }

    changing do
      def update_kind(kind, url = nil)
        @kind    = EXAMPLES.keys.include?(kind) ? kind : 'blank'
        @example = new EXAMPLES[self.kind], :url => url
      end
    end

    def from_url(url)
      if url
        kind, rest = url.split('/', 2)
        self.update_kind kind, rest
      else
        self.update_kind 'blank'
      end
    end

    def to_url
      "#{kind}/#{example.to_url}"
    end

    def content(b)
      b.ul do
        EXAMPLES.keys.each do |name|
          b.li { b.a(name).action { self.update_kind name } }
        end
      end
      b.hr
      b.c example
    end
  end
end

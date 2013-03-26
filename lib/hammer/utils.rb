module Hammer::Utils
  def self.benchmark(logger, level, label, req = true, &block)
    ret  = nil
    time = Benchmark.realtime { ret = block.call }
    logger.send level, if req
                         "#{label} in %0.6f sec ~ %.2f req/s" % [time, (1/time)]
                       else
                         "#{label} in %0.6f sec"
                       end
    return ret
  end

  def self.safely(&block)
    r = block.call
  rescue => e
    [false, e]
  else
    [true, r]
  end

  module AbstractClasses
    def abstract!
      @abstract = true
    end

    def abstract?
      !!@abstract
    end
  end

  module FindAdapter
    def [](name)
      abstract = self.const_get :Abstract
      abstract.subclasses.find { |c| c.name == name } || raise("unknown adapter #{name}")
    end
  end

end
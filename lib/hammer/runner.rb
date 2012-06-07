module Hammer
  class Runner
    require 'hammer/runner/node'

    attr_reader :config, :logger, :core, :node

    def initialize
      #load_app

      @config = Hammer::Config.new
      @core   = Hammer::Core.new config
      @logger = core.logging['runner']

      logger.info "Configuration:\n" + config.config_values.pretty_inspect.chop!
      #DataMapper::Logger.new(Hammer.config[:logger][:output]) # TODO

      @node = Node.new(core).run if core.config.node.run

      run_event_machine
    end

    def run_event_machine
      EventMachine.run do
        logger.info "event machine running"
        Signal.trap("INT") { stop_event_machine }
        Signal.trap("TERM") { stop_event_machine }
      end
    end

    private

    def stop_event_machine
      logger.info 'event machine stopping'
      EventMachine.stop
      logger.info 'event machine stopped'
    end

    def load_app
      load_app_files
      # generate_css
      # setup_db
    end

    def load_app_files
      Hammer::Loader.new(Dir.glob('./app/**/*.rb')).load! # TODO configurable path, default detection
    end

    #def generate_css
    #  Hammer.benchmark('== CSS generated', false) do
    #    File.open("./public/css/#{Hammer.config.app.project.underscore}.css", 'w') do |file|
    #      file.write Hammer::Widget::CSS.css
    #    end
    #  end
    #end

    #def setup_db
    #  if Hammer.config.app[:db] && Hammer.config.app.db[Hammer.config.environment]
    #    DataMapper.finalize
    #    DataMapper.setup :default, Hammer.config.app.db[Hammer.config.environment]
    #    Hammer.logger.info "== DB: #{Hammer.config.app.db[Hammer.config.environment]}"
    #  end
    #end

  end
end

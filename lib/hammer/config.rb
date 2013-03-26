module Hammer

  class Configuration < Configliere::Param
    def method_missing(method, *args, &block)
      if key? method
        self[method]
      else
        super(method, *args, &block)
      end
    end

    def respond_to_missing?(symbol, include_private = false)
      key? symbol
    end
  end

  class Config
    def initialize(options = {})
      @config = new_configuration(options)
    end

    def method_missing(method, *args, &block)
      if @config.respond_to?(method)
        @config.send method, *args, &block
      else
        super
      end
    end

    def config_values
      @config
    end

    private

    def new_configuration(options)
      config = Configuration.new
      config.use :define, :config_file, :commandline, :config_block
      #c.deep_merge! options

      config.define 'environment',
                    :type        => Symbol,
                    :required    => true,
                    :default     => :development,
                    :description => "environment",
                    :env_var     => 'RACK_ENV'
      config.define 'root',
                    :required    => true,
                    :default     => File.expand_path(File.join(File.dirname(__FILE__), '..')),
                    :description => "Hammer gem root file path"

      argv_help_hack { config.resolve! }


      config.define 'app.shared',
                    :required    => true,
                    :default     => "Hammer::Core::Shared",
                    :description => "class for shared data"
      config.define 'app.apps',
                    :required    => true,
                    :default     => { 'examples' => { :class => 'Hammer::Components::Examples', :main => true } },
                    :description => "apps configuration"
      config.define 'app.context',
                    :required    => true,
                    :default     => 'Hammer::Core::Context',
                    :description => "names of context class"
      config.define 'app.public',
                    :required    => true,
                    :default     => File.join(config.root, 'hammer', 'public'),
                    :description => 'path to the application'


      # TODO move node settings under adapter key(zmq_node)

      config.define 'node.web.host', # TODO move to app settings
                    :required    => true,
                    :default     => '127.0.0.1',
                    :description => "web-server's device to bind"
      config.define 'node.web.port', # TODO move to app settings
                    :type        => Integer,
                    :required    => true,
                    :default     => 3000,
                    :description => "web-server's port"
      config.define 'node.executable',
                    :required => true,
                    :default  => '/usr/local/bin/node'
      config.define 'node.run',
                    :type     => :boolean,
                    :required => true,
                    :default  => true
      config.define 'node.to_hammer',
                    :required    => true,
                    :default     => 'tcp://127.0.0.1:4211',
                    :description => "zmq channel to hammer"
      config.define 'node.to_node',
                    :required    => true,
                    :default     => 'tcp://127.0.0.1:4210',
                    :description => "zmq channel to hammer"
      config.define 'node.log_traffic',
                    :required    => true,
                    :default     => false,
                    :description => "log node traffic"


      config.define 'core.fibers',
                    :type        => Integer,
                    :required    => true,
                    :default     => 100,
                    :description => "size of fiberpool"
      config.define 'core.message_adapter',
                    :required    => true,
                    :default     => 'em-websocket',
                    #:default     => 'node_zmq',
                    :description => 'name of the messaging adapter'
      config.define 'core.html_client',
                    :required    => true,
                    :default     => 'normal',
                    :description => "name of a html client adapter"
      config.define 'core.websocket_url', # TODO move to app settings
                    :required    => true,
                    #:default     => 'http://localhost:3000',
                    :default     => 'ws://localhost:3001',
                    :description => 'url to a WebSocket server'



      config.define 'logger.level.fallback',
                    :default     => config[:environment] == :development ? 0 : 1,
                    :required    => true,
                    :description => "default logger level"
      config.define 'logger.level.adapter', :default => 2
      config.define 'logger.output',
                    :required    => true,
                    :default     => $stdout,
                    :description => "log's file name"

      #config.read './config.yml'
      # TODO load config by app.root_path
      # TODO add app.root_path

      config.resolve!
      config
    end

    def argv_help_hack(argv = ARGV)
      old_argv = argv.clone
      argv.delete '--help' if argv.include? '--help'
      yield
    ensure
      argv.replace old_argv
    end
  end
end




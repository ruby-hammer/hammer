# encoding: UTF-8

module Hammer
  module Config

    def self.included(base)
      base.extend ClassMethods
    end

    def config
      self.class.config
    end

    module ClassMethods
      def config
        @@config ||= begin Configliere.new.instance_eval do
            use :define, :config_file, :commandline, :config_block

            [

              # name                    type      default       description
              [ 'web.host',             String,   '127.0.0.1',  "web-server's device to bind" ],
              [ 'web.port',             Integer,  3000,         "web-server's port" ],

              [ 'websocket.host',       String,   '127.0.0.1',  "websocket-server's device to bind" ],
              [ 'websocket.server',     String,   '127.0.0.1',  "websocket-server's address for clients" ],
              [ 'websocket.port',       Integer,  3001,         "websocket-server's port" ],
              [ 'websocket.debug',      :boolean, false,        "show raw websocket's communication?" ],

              [ 'core.devel',           String,   'devel',      "hash address of devel tools" ],
              [ 'core.fibers',          Integer,  20,           "size of fiberpool" ],

              [ 'logger.level',         Integer,  0,            "logger level" ],
              [ 'logger.show_traffic',  :boolean, false,        "show server-client formated communication" ],
              [ 'logger.output',        nil,      $stdout,      "log's file name" ],

              [ :root,                  String,   nil,          "name of a root component's class" ],
              [ :layout,                String,   "Hammer::Widget::Layout", "name of a layout's class" ],
              [ :environment,           Symbol,   :development, "environment", 'RACK_ENV' ],
              [ :irb,                   :boolean, false,        "run console" ]


            ].each do |key, type, default, description, env_var|
              options = { :description => description }
              options[:type] = type if type
              options[:default] = default unless default.nil?
              options[:env_var] = env_var if env_var

              define key, options
            end

            finally do |c|
              c[:irb] = c[:environment] == :development
            end

            read './config.yml'
            resolve!
            self
          end
        end
      end
    end
  end
end




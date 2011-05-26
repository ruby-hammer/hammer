# encoding: UTF-8

module Hammer::Runner

  include Hammer::Config

  class << self

    def run!
      load_app
      Hammer::Core::WebSocketServer.run!
      setup_application
      Hammer.logger.info "== Settings\n" + config.pretty_inspect
      Hammer.logger.level = config[:logger][:level]
      Hammer::Core::WebServer.run!
    end

    def load_app
      load_app_files
      generate_css
      setup_db
    end

    def load_app_files
      Hammer::Loader.new(Dir.glob('./app/**/*.rb')).load!
      Hammer.run_after_load!
    end

    def generate_css
      Hammer.benchmark('== CSS generated', false) do
        File.open("./public/css/#{config[:app][:name].underscore}.css", 'w') do |file|
          file.write Hammer::Widget::CSS.css
        end
      end
    end

    def setup_db
      if config[:app][:db] && config[:app][:db][config[:environment]]
        DataMapper.finalize
        DataMapper.setup :default, config[:app][:db][config[:environment]]
        Hammer.logger.info "== DB: #{config[:app][:db][config[:environment]]}"
      end
    end

    private

    def setup_application
      Hammer::Core::WebServer.set \
          :root => Dir.pwd,
          :host => config[:web][:host],
          :port => config[:web][:port],
          :environment => config[:web][:environment]
    end
  end
end

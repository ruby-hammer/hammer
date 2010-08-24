# encoding: UTF-8

module Hammer::Runner

  include Hammer::Config

  class << self

    def run!
      #          encoding
      load_app_files
      generate_css
      Hammer::Core::Base.run!
      setup_application
      Hammer.logger.info "== Settings\n" + config.pretty_inspect
      Hammer.logger.level = config[:logger][:level]
      #        if config[:irb]
      #          require 'irb'
      #          Thread.new { IRB.start }
      #        end
      Hammer::Core::Application.run!
    end

    def load_app_files
      Hammer::Loader.new(Dir.glob('./**/*.rb')).load!
    end

    def generate_css
      Hammer.benchmark('css generated', false) do
        File.open('./public/css/app.css', 'w') do |file|
          file.write Hammer::Widget::CSS.css
        end
      end
    end

    private

    def setup_application
      Hammer::Core::Application.set \
          :root => Dir.pwd,
          :host => config[:web][:host],
          :port => config[:web][:port],
          :environment => config[:web][:environment]
    end
  end
end

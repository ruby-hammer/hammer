# encoding: UTF-8

unless defined? Hammer
  # gems
  require 'active_support/core_ext'
  require 'active_support/basic_object'
  require 'active_support/json'
  require 'erector'
  require 'sinatra/base'
  require 'em-websocket'
  require 'configliere'

  # stdlib
  require 'pp'
  require 'fiber'
  require 'benchmark'

  # hammer
  require 'hammer/config.rb'

  module Hammer

    include Hammer::Config

    def self.logger
      @logger ||= Hammer::Logger.new(config[:logger][:output])
    end

    def self.v19?
      RUBY_VERSION =~ /1.9/
    end

    def self.benchmark(label, req = true, &block)
      time = Benchmark.realtime { block.call }
      Hammer.logger.info "#{label} in %0.6f sec" % time unless req
      Hammer.logger.info "#{label} in %0.6f sec ~ %d req" % [time, (1/time).to_i] if req
    end

    # @return [Hammer::Core::Context, nil] context where is current code running or nil when core is running outside
    # a context
    def self.get_context
      return nil unless Fiber.current.respond_to? :hammer_context
      Fiber.current.hammer_context || raise('unset context in fiber')
    end

  end

  require 'hammer/load.rb'

  #  files = Dir.glob("#{File.expand_path(File.dirname(__FILE__))}/hammer/**/*.rb")
  #  Hammer::Loader.new(files).load!

  # require 'datamapper'
  # require "#{Hammer.root}/lib/setup_db.rb"
  # DataMapper.setup(:default, 'sqlite3://memory')
  # DataMapper.auto_migrate!
end

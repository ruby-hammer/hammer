# encoding: UTF-8

unless defined? Hammer
  require 'active_support/core_ext'
  require 'active_support/basic_object'
  require 'active_support/json'
  require 'erector'
  require 'sinatra/base'
  require 'em-websocket'
  require 'configliere'
  require 'hammer/fiber'
  require 'data_objects'
  require 'hammer/monkey/data_objects_em_fiber'
  require 'datamapper'  
  require 'pp'
  require 'benchmark'

  require 'hammer/config.rb'

  module Hammer

    include Hammer::Config

    def self.logger
      @logger ||= Hammer::Logger.new(config[:logger][:output], config[:logger][:level])
    end

    def self.v19?
      defined? @v19 ? @v19 : RUBY_VERSION =~ /1.9/
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

    def self.after_load(&block)
      @after_load ||= []
      @after_load << block
    end

    def self.run_after_load!
      [*@after_load].each {|proc| proc.call }
      @after_load = []
    end
  end

  DataMapper::Logger.new(Hammer.config[:logger][:output]) # TODO

  require 'hammer/monkey/basic_object'
  require 'hammer/load.rb'

  Hammer.run_after_load!

  #  files = Dir.glob("#{File.expand_path(File.dirname(__FILE__))}/hammer/**/*.rb")
  #  Hammer::Loader.new(files).load!

  # require 'datamapper'
  # require "#{Hammer.root}/lib/setup_db.rb"
  # DataMapper.setup(:default, 'sqlite3://memory')
  # DataMapper.auto_migrate!
end

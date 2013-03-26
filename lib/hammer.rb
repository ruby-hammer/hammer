# FIXME dropping of contexts

# TODO use dependency injection pattern
# TODO define container modules in one file
# TODO auto loading with loader

# Weak collections -> loosers
# hammer-builder -> showoff

module Hammer
  def self.v19?
    @v19 ||= RUBY_VERSION =~ /1.9/
  end
end

# required gems
require 'multi_json'
require 'active_support/basic_object'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/blank'
require 'pp'
require 'benchmark'
require 'eventmachine'
require 'hammer_builder'
require 'hammer-weak'
require 'hammer-actor'
require 'configliere'
require 'securerandom'
require 'radix62'
require 'log4r'
begin
  require 'pry'
rescue LoadError
  # ignored
end

#require 'data_objects'
#require 'datamapper'

require 'hammer/current_app'
require 'hammer/builder'
require 'hammer/config'
require 'hammer/utils'
require 'hammer/observable'
require 'hammer/observer'
require 'hammer/component'
require 'hammer/runner'
require 'hammer/loader'
require 'hammer/message'
require 'hammer/core'
require 'hammer/apps'
require 'hammer/app_components'
require 'hammer/components'

require 'hammer/monkey/basic_object' if defined? ActiveSupport::BasicObject
require 'hammer/monkey/proc'
require 'hammer/monkey/data_objects_em_fiber' if defined? DataObjects
require 'hammer/monkey/weak_identity_map' if defined? DataMapper


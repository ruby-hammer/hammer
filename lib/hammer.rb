
module Hammer
  def self.v19?
    @v19 ||= RUBY_VERSION =~ /1.9/
  end
end

# required gems
require 'yajl/json_gem'
require 'active_support/basic_object'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/blank'
require 'pp'
require 'benchmark'
require 'eventmachine'
require 'zmq'
require 'hammer_builder'
require 'configliere'
require 'securerandom'
require 'radix62'
require 'log4r'

#require 'data_objects'
#require 'datamapper'

root = File.expand_path(File.dirname(__FILE__))
$: << root unless $:.include? root

require 'hammer/builder'
require 'hammer/config'
require 'hammer/weak'
require 'hammer/utils'
require 'hammer/component'
require 'hammer/observable'
require 'hammer/observer'
require 'hammer/runner'
require 'hammer/loader'
require 'hammer/message'
require 'hammer/core'
require 'hammer/app'
require 'hammer/app_components'
require 'hammer/components'

require 'hammer/monkey/basic_object' if defined? ActiveSupport::BasicObject
require 'hammer/monkey/proc'
require 'hammer/monkey/data_objects_em_fiber' if defined? DataObjects
require 'hammer/monkey/weak_identity_map' if defined? DataMapper


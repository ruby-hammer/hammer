module Hammer
  # represents component of a page. The basic logic building blocks of a application.
  class Component

    require "hammer/component/state.rb"
    require "hammer/component/updater.rb"
    require "hammer/component/actions.rb"
    require "hammer/component/state_helper.rb"

    extend StateHelper
    extend HammerBuilder::Helper
    include Hammer::Observable::Helper
    include Hammer::Observer::Helper

    attr_reader :actions, :state, :updater, :app

    class << self
      private :new
    end

    # stores assigns into instance_variables
    def initialize(app, options = { })
      @app     = app || raise(ArgumentError, 'no app')
      @actions = Hammer::Component::Actions.new(self)
      @state   = Hammer::Component::State.new
      @updater = Hammer::Component::Updater.new(self)

      from_url options[:url]
    end

    def new(klass, *args, &block)
      klass.send :new, app, *args, &block
    end

    def core
      app.context.container.core
    end

    def context
      app.context
    end

    #def root
    #  context.root
    #end

    # FIND dangerous?, add own ids to components an store hash on context
    def self.get(id)
      obj = ObjectSpace._id2ref(id.to_i)
      return nil unless obj.kind_of? Component
      return obj
    rescue RangeError
    end

    def id
      "c" + object_id.to_s
    end

    #def self.shared(*names)
    #  delegate(*(names + [{ :to => :shared }]))
    #end

    #def shared
    #  context.container.shared
    #end

    def wrapper(builder, content = false)
      tag = wrapper_options(builder.send wrapper_tag)
      tag.with { content builder } if content
      builder
    end

    def wrapper_tag
      :div
    end

    # @param [HammerBuilder::AbstractDoubleTag] tag
    # @return [HammerBuilder::AbstractDoubleTag]
    def wrapper_options(tag)
      tag[self].class 'component'
    end

    def self.hammer_builder_ref
      @css_class ||= self.to_s.underscore.gsub '/', '-'
    end

    def hammer_builder_ref
      id
    end

    def content(builder)
      raise NotImplementedError
    end

    def as_json
      raise NotImplementedError
    end

    def to_url
      raise NotImplementedError
    end

    def from_url(url)
      raise ArgumentError, 'implement from_url for non nil values' unless url.nil?
    end

#    include Answering
#    include Passing
#    include Inspection

  end
end


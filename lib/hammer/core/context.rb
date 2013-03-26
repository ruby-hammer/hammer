module Hammer
  # represents context of user, each tab of a browser has one
  class Core::Context

    attr_reader :id, :container, :apps, :logger, :main_app, :title

    # @param [String] id unique identification
    def initialize(id, container, url, options = {})
      @id        = id
      @container = container
      @apps      = {}
      @logger    = core.logging['context']
      #@repository   = DataMapper.repository(:default)

      logger.debug "new #{id}"
      apps['title'] = @title = Apps::Title.new(self, 'title')
      from_url url
    end

    private_class_method :new

    #def clone()
    #  copy = super
    #  copy.instance_eval do
    #
    #  end
    #end

    def core
      container.core
    end

    def app(id)
      apps[id]
    end

    # remove context form container
    def drop
      logger.debug "drop #{id}"
      container.drop_context(self)
    end

    def to_url
      main_app.to_url
    end

    def from_url(url)
      unless core.config.app.apps.select { |id, options| options[:main] }.size == 1
        raise 'only one main app is allowed'
      end

      core.config.app.apps.each do |id, options|
        id, klass_name, main = id.to_s, *options.values_at(:class, :main)
        klass                = klass_name.constantize
        apps[id]             = Apps::App.new(self, id, :url => (main ? url : nil), :root_class => klass)
        @main_app = apps[id] if main
      end
    end

    def receive_message(message)
      unless message.context_id == id
        raise ArgumentError, 'wrong context_id'
      end

      if message.type == 'drop'
        drop
        return
      end

      unless (app = app(message.app_id))
        logger.warn "no app with id: '#{message.app_id}'"
      else
        app.receive_message(message)
      end
    end

    def send_message(message)
      message.context_id ||= id
      message.url        = to_url
      container.send_message(message)
    end
  end
end


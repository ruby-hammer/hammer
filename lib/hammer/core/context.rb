module Hammer
  # represents context of user, each tab of a browser has one
  class Core::Context

    attr_reader :id, :container, :apps, :logger, :connection_id

    # @param [String] id unique identification
    def initialize(id, container, url, options = { })
      @id        = id
      @container = container
      @apps      = { }
      @logger    = core.logging['context']
      #@repository   = DataMapper.repository(:default)

      logger.debug "new #{id}"
      from_url url
    end

    def core
      container.core
    end

    def app(id)
      apps[id]
    end

    # remove context form container
    def drop
      container.drop_context(self)
    end

    def to_url
      app(core.config.app.main).to_url
    end

    def from_url(url)
      apps['title'] = @title = App.new(self, 'title', nil) { |app| AppComponents::Title.send :new, app }
      core.config.app.apps.each do |id, klass_name|
        main      = (core.config.app.main == id.to_s)
        id, klass = id.to_s, klass_name.constantize
        apps[id]  = App.new(self, id, main ? url : nil) do |app, url|
          AppComponents::Simple.send :new, app, klass.send(:new, app, :url => url)
        end
      end
    end

    def receive_message(message)
      unless app = app(message.app_id)
        logger.warn "no app with id: '#{message.app_id}'"
      else
        message.context_id ||= id # if new connection, message does not have one
        @connection_id     = message.connection_id
        app.receive_message(message)
      end
    end

    def send_message(message)
      message.connection_id ||= @connection_id
      message.url           = to_url
      container.send_message(message)
    end
  end
end


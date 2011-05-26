# encoding: UTF-8

module Hammer::Core
  # TODO remove Sinatra dependenci
  class WebServer < Sinatra::Base
    include Hammer::Config

    use CommonLogger, Hammer.logger
    use Rack::Session::Pool

    set(
      :logging => false,
      :server => %w[thin]
    )

    configure(:production) do
      Hammer.logger.level = Logger::Severity::INFO
    end

    # @return [String] session_id
    def session_id
      request.session_options[:id]
    end

    get '/*' do
      Hammer::Core::Base.get_content(session_id, params[:splat])
    end

  end
end

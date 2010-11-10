# encoding: UTF-8

module Hammer::Widget

  # Abstract layout for Hammer applications
  class Layout < Erector::Widgets::Page

    include Hammer::Widget::JQuery
    needs :session_id

    depends_on :js, 'websocket/swfobject.js'
    depends_on :js, 'websocket/FABridge.js'
    depends_on :js, 'websocket/web_socket.js'

    depends_on :js, 'hammer/jquery-1.4.2.js'
    depends_on :js, 'hammer/jquery.ba-hashchange.js'
    depends_on :js, 'hammer/jquery-no_conflict.js'
    depends_on :js, 'right/right-safe-src.js'
    depends_on :js, 'right/right-dnd-src.js'
#    depends_on :js, 'rightjs/javascripts/right-olds-src.js'
    depends_on :js, 'hammer/hammer.js'

    depends_on :css, "css/#{Hammer.config[:app][:name].underscore}.css" if Hammer.config['app.name']

    def body_content
      set_variables(@session_id)
      loading
      container { div :id => 'hammer-content' }
    end

    def container(&content)
      content.call
    end

    # overwrite to change loading page
    def loading
      div(:id => 'hammer-loading') { text 'Loading ...' }
    end

    def head_content
      super
      link :rel => "shortcut icon", :href => favicon
    end

    # overwrite to change favicon
    # @return [String] favicon path
    def favicon
      "hammer/hammer.png"
    end

    protected

    def self.generated_css
      depends_on :css, "css/#{Hammer.config[:app][:name].underscore}.css" if Hammer.config['app.name']
    end

    private

    # sets configuration
    def set_variables(session_id)
      javascript(jquery do
          call(:Hammer).setOptions(
            :server => Hammer.config[:websocket][:server],
            :port => Hammer.config[:websocket][:port],
            :sessionId => session_id)
        end + "WEB_SOCKET_SWF_LOCATION = \"websocket/WebSocketMain.swf\""
      )
    end
  end
end
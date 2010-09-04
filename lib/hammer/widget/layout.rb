# encoding: UTF-8

module Hammer::Widget

  # Abstract layout for Hammer applications
  class Layout < Erector::Widgets::Page

    include Hammer::Widget::JQuery
    needs :session_id

    depends_on :js, 'js/swfobject.js'
    depends_on :js, 'js/FABridge.js'
    depends_on :js, 'js/web_socket.js'
    
    depends_on :js, 'js/jquery-1.4.2.js'
    depends_on :js, 'js/jquery.ba-hashchange.js'
    depends_on :js, 'js/jquery-no_conflict.js'
    depends_on :js, 'js/right.js'
    depends_on :js, 'js/hammer.js'
    depends_on :css, "css/#{Hammer.config[:app][:name].underscore}.css" if Hammer.config[:app][:name]
    depends_on :'shortcut icon',"hammer.png"
    #

    def body_content
      set_variables(@session_id)
      loading
      div :id => 'hammer-content'
    end

    # overwrite to change loading page
    def loading
      div(:id => 'hammer-loading') { text 'Loading ...' }
    end

    def head_content
      super
      link :rel => "shortcut icon", :href => favicon
    end

    def favicon
      "hammer.png"
    end

    private

    # sets configuration
    def set_variables(session_id)
      javascript(jquery do
          call(:Hammer).setOptions(
            :server => Hammer.config[:websocket][:server],
            :port => Hammer.config[:websocket][:port],
            :sessionId => session_id)
        end + "WEB_SOCKET_SWF_LOCATION = \"WebSocketMain.swf\""
      )
    end
  end
end
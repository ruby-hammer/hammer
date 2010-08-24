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
    depends_on :js, 'js/jquery-ui-1.8.2.custom.min.js'
    depends_on :js, 'js/jquery.ba-hashchange.js'
    depends_on :js, 'js/jquery.namespace.js'
    depends_on :js, 'js/hammer.js'

    depends_on :css,'css/app.css'

    def body_content
      set_variables(@session_id)
      loading
      div :id => 'hammer-content'
    end

    # overwrite to change loading page
    def loading
      div(:id => 'hammer-loading') { text 'Loading ...' }
    end

    def self.use_blueprint
      class_eval do
        def head_content
          super
          rawtext <<CSSHEADERS
<link rel="stylesheet" href="css/blueprint/screen.css" type="text/css" media="screen, projection">
<link rel="stylesheet" href="css/blueprint/print.css" type="text/css" media="print">
<!--[if lt IE 8]><link rel="stylesheet" href="css/blueprint/ie.css" type="text/css" media="screen, projection"><![endif]-->
CSSHEADERS
        end
      end
    end

    private

    # sets configuration
    def set_variables(session_id)
      javascript(jquery do
          jQuery!.hammer.setSettings(
            :server => Hammer.config[:websocket][:server],
            :port => Hammer.config[:websocket][:port],
            :sessionId => session_id)
        end + "WEB_SOCKET_SWF_LOCATION = \"WebSocketMain.swf\""
      )
    end
  end
end
# encoding: UTF-8

module Hammer::Widget

  # Abstract layout for Hammer applications
  class Layout < Erector::Widgets::Page

    include Hammer::Widget::JQuery
    needs :session_id

    #      depends_on :js, 'js/swfobject.js', 'js/FABridge.js', 'js/web_socket.js'
    depends_on :js, 'js/jquery-1.4.2.js'
    depends_on :js, 'js/jquery-ui-1.8.2.custom.min.js'
    depends_on :js, 'js/jquery.ba-hashchange.js'
    depends_on :js, 'js/jquery.namespace.js'
    depends_on :js, 'js/hammer.js'

    depends_on :css,'css/developer.css'
    external :css, "css/ui-lightness/jquery-ui-1.8.2.custom.css"

    def body_content
      set_variables(@session_id)
      loading
    end

    # overwrite to change loading page
    def loading
      div(:class => 'loading') { img :src => 'img/loading.gif', :alt => "Loading..." }
    end

    private

    # sets configuration
    def set_variables(session_id)
      javascript(jquery do
          jQuery!.hammer.setSettings(
            :server => Hammer.config[:websocket][:server],
            :port => Hammer.config[:websocket][:port],
            :sessionId => session_id)
        end)
    end
  end
end
# encoding: UTF-8

class Chat::Layout < Hammer::Widget::Layout

  external :css, "css/basic.css"
  external :css, "css/chat.css"

  def page_title
    "Hammer - Chat"
  end

end
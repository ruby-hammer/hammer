# encoding: UTF-8

module Hammer::Widget

  class Base < Abstract
    include Wrapping
    include Component
    include Passing
    # include Hammer::Widget::ElementBuilder
    include JQuery
    include CSS

    include Helper::LinkTo
  end

end
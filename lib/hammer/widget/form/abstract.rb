module Hammer::Widget::Form
  class Abstract < Hammer::Widget::Base
    wrap_in(:div)
    needs \
        :value => :value,
        :options => {},
        :label_options => {},
        :label => nil

    def content
      render_label
      field
    end

    def render_label
      label @label, { :for => @label_id = Hammer::Core.generate_id }.merge(@label_options) if @label
    end

  end
end
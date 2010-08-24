module Hammer::Widget::State
  # adds css class 'changed' to widgets of changed components
  def wrapper_classes
    changed? ? super << 'changed' : super
  end

  # resets component after rendering FIXME maybe should be done manually after rendering
  def _render(options = {}, &block)
    html = super
    component.reset!
    return html
  end

  def render(obj)
    if obj.kind_of?(Hammer::Component::Base)
      render_component(obj)
    else super
    end
  end

  protected

  # renders replacer in place of component when rendering update
  def render_component(component)
    unless render_options[:update]
      widget component.widget
    else
      replacer(component)
    end
  end

  private

  def replacer(component)
    span :'data-component-replace' => component.object_id
  end
end

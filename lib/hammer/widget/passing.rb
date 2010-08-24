module Hammer::Widget::Passing
  def wrapper_classes
    component.passed? ? super << 'passed' : super
  end

  protected

  def call_content_method
    if component.passed?
      wrapper { render component.passed_on }
    else
      super
    end
  end
end

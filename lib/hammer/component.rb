module Hammer::Component
  class ComponentException < StandardError; end
  class MissingWidgetClass < ComponentException; end

  def self.all
    Hammer::Component::Base.descendants
  end
end
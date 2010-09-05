module Hammer::Component::Sharing
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def shared(*names)
      delegate(*names, :to => :shared)
    end
  end

  def shared
    context.container.shared
  end
end
module Hammer::CurrentApp
  def current_app
    return nil unless Fiber.current.respond_to? :hammer_app
    Fiber.current.hammer_app || raise('unset app in fiber')
  end
end

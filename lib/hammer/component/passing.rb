module Hammer::Component::Passing

  def self.included(base)
    base.children :passed_on
    base.send :attr_reader, :passed_on
  end

  # rendering is passed on to +component+. Usually used with ask.
  # @return [Base]
  # @example
  #   pass_on ask(Login, Model::User.new) { |user|
  #     do_something_with_returned_user
  #     retake_control!
  #   }
  def pass_on(component)
    change!
    @passed_on = component
  end

  # see {#pass_on}
  def retake_control!
    change!
    @passed_on = nil
  end

  # @return [Boolean] is component passing?
  def passed?
    @passed_on.present?
  end

  protected

  def children_update(options)
    passed? ? passed_on.to_html(options) : super
  end

end
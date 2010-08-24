module Hammer::Component::Answering

  # asks a +component+ for something and executes +block+ when answer is obtained
  # @param [Class, Base] component which is asked
  # @yield [Object] block answer block which is executed after answer is obtained
  # @example with a {Base} instance
  #   ask self.counter do |answer|
  #     values << answer
  #   end
  # @return [Base] created or passed component
  def ask(component, &block)
    component.answering!(self, &block)
  end

  # sets component to answer +to_whom+
  # @param [Base] to_whom
  # @yield block to execute after answer
  # @return self
  # @see #ask
  def answering!(to_whom, &block)
    @asker, @askers_callback = to_whom, block
    self
  end

  # @return [Boolean] am I answering to a component?
  def answering?
    @asker.present?
  end

  # answers with +answer+
  # @param [Object] answer passed to stored block
  # @see #ask
  def answer!(answer = nil)
    raise 'not answering' unless answering?
    @asker.instance_exec answer, &@askers_callback
  end

end
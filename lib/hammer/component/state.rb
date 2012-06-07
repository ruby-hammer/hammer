class Hammer::Component::State
  def initialize
    @changed = true
    @sent    = false
  end

  # @return [Boolean] if component id changed
  def changed?
    @changed
  end

  # is updated html sended to client?
  def sent?
    @sent
  end

  # tells component that it's changed
  def change!
    @changed = true
    new!
  end

  # resets component change state
  def unchange!
    @changed = false
    self
  end

  # set update to unsent?
  def new!
    @sent = false
    self
  end

  # set update to sent
  def send!
    @sent = true
    self
  end
end


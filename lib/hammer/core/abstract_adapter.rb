class Hammer::Core::AbstractAdapter

  extend Hammer::Utils::AbstractClasses
  abstract!

  def self.inherited(klass)
    @subclasses ||= []
    @subclasses << klass
  end

  def self.subclasses
    @subclasses ||= []
  end

  def self.name
    raise NotImplementedError
  end
end
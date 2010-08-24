module Hammer::Component::Traversing

  def self.included(base)
    base.extend ClassMethods
    base.class_inheritable_array :component_readers, :instance_reader => false, :instance_writer => false
  end

  module ClassMethods
    # @param [Array<Symbol>] names of methods returning children components. They can return component or
    # array of components.
    def children(*names)
      self.component_readers = names
    end
  end

  # @return [Hash{Symbol => Array<Hammer::Component::Base>}] hash of children components identified by name of
  # retrieving method
  def children_by_name
    self.class.component_readers.inject({}) {|hash, name| hash.merge :name => get_components(name) }
  end

  # @return [Array<Hammer::Component::Base>] of children components
  def children
    self.class.component_readers.inject([]) {|arr, name| arr + get_components(name) }
  end

  # @return [Array<Hammer::Component::Base>] all children, self included
  def all_children
    children.inject([self]) {|arr, child| arr + child.all_children }
  end

  private

  # retrieves component and checks if returned value is correct.
  def get_components(method)
    components = [*send(method)].compact
    unless components.all? {|c| c.kind_of?(Hammer::Component::Base) }
      raise ArgumentError, "method #{method} of #{self.class} returned #{components}"
    end
    components
  end

end
class Hammer::Component::Updater
  attr_reader :component

  def initialize(component)
    @component = component
    @update    = nil
    @children  = []
  end

  # @return [String] rendered html
  def update
    if component.state.changed? || !@update
      component.actions.clear
      old_children = @children
      @update      = component.core.hammer_builder_pool.get.component(component, true).to_html!
      component.state.unchange!
      # mark unchanged rendered components to send
      (children - old_children).each { |component| component.all_children.map { |c| c.state.new! } }
    end
    @update
  end

  #def to_xhtml
  #  Hammer::Builder.get.component(component, true).to_xhtml
  #end

  # @return [Array<Hammer::Component::Base>] of children components
  def children
    update if component.state.changed?
    @children
  end

  # @return [Array<Hammer::Component::Base>] all children, self included
  def all_children
    children.inject([component]) { |arr, child| arr + child.updater.all_children }
  end

  # @return [Array<Hammer::Bomponent::Base>] of unsent? visible components
  def all_unsent_components
    all_children.select { |component| not component.state.sent? }
  end

  # @private
  def children_array
    @children
  end

end

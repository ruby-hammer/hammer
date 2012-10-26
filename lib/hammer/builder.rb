module Hammer
  class Builder < HammerBuilder::Standard

    dynamic_classes do
      extend_class :AbstractTag do
        def action(name = 'action', &block)
          data name => builder.rendered_component.actions.register(&block)
        end
      end

      extend_class :A do
        strings_injector.add :hash, '#'

        def action(name = 'action', &block)
          super(name, &block)
          href @_str_hash
        end
      end
    end

    def component(object, *args, &block)
      if !args[0].is_a?(Symbol)
        add_component_child object
        update_component_children(object) do
          object.wrapper self, args[0]
        end
        return self
      end

      raise unless rendered_component == object # assert
      render object, *args, &block
    end

    alias_method :c, :component

    attr_reader :rendered_component

    def initialize
      @rendered_component = nil
      super
    end

    def reset
      @rendered_component = nil
      super
    end

    # TODO extract these methods into some context/option class
    # add support for default wrapper options to render the whole page

    private

    def update_component_children(component)
      old_rendered_component = @rendered_component
      @rendered_component    = component
      component.updater.children_array.clear
      yield
      @rendered_component = old_rendered_component
    end

    def add_component_child(component)
      @rendered_component.updater.children_array << component if @rendered_component
    end

  end

end

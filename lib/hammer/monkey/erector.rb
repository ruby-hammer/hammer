# adds hooks. it doesn't change functionality
module Erector
  class AbstractWidget

    protected

    def _render(options = {}, &block)
      @_block   = block if block
      @_parent  = options[:parent]  || parent
      @_helpers = options[:helpers] || parent
      @_output  = options[:output]
      @_output  = Output.new(options) unless output.is_a?(Output)
      @_render_options = options

      output.widgets << self.class
      call_content_method
      output
    end

    def render_options
      @_render_options || raise('render_options are not set yet')
    end

    def call_content_method
      send render_options[:content_method_name] || :content
    end

  end
end
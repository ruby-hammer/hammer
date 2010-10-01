# encoding: UTF-8

module Hammer::Core
  class Shared
    include Observable
  end

  # Manages all context of one user.
  # This is the one object which is stored in session.
  class Container

    attr_reader :id, :shared
    def initialize(id)
      @id, @contexts, @shared = id, {}, Hammer.config[:app][:shared].constantize.new
    end

    # @return [Base, nil] {Base} with +id+
    # @param [String] id of a {Base}
    def context(id = nil, hash = nil)
      @contexts[id] || begin
        id = Hammer::Core.generate_id
        @contexts[id] = Context.new(id, self, hash)
      end
    end

    # @param [Context] context to drop when is not needed
    def drop_context(context)
      @contexts.delete(context.id)
      drop if @contexts.empty?
    end

    # drops container when is not needed
    def drop
      Base.drop_container(self)
    end

    # context's count
    def size
      @contexts.size
    end

  end
end

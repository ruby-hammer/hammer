# encoding: UTF-8

# TODO remove contexts to other class
module Hammer::Core
  class Base
    include Hammer::Config

    @containers = {}

    # @return [Container] container by user_id (session id is used)
    def self.container(user_id)
      @containers[user_id] ||= Container.new(user_id)
    end

    # delete container where isn't needed any more
    def self.drop_container(container)
      @containers.delete(container.id) || raise
    end

    @fibers_pool = Hammer::Core::FiberPool.new config[:core][:fibers]

    # @return [Hammer::Core::FiberPool]
    def self.fibers_pool
      @fibers_pool
    end

    def self.get_content(session_id, url) # TODO
      config[:layout].to_s.constantize.new(:session_id => session_id).to_html
    end

    def self.run_actions(session_id, context_id, actions)
      context = self.container(session_id).try :context, context_id
      context.schedule do
        actions.each do |action_id, args|
          context.run_action(action_id, args)
        end
      end if context # TODO catch
    end

    def self.update_values(session_id, context_id, values)
      context = self.container(session_id).try :context, context_id
      context.schedule do
        context.update_form(values)
      end if context # TODO catch
    end

  end
end

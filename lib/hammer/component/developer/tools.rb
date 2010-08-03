# encoding: UTF-8

module Hammer::Component::Developer
  class Tools < Hammer::Component::Base

    attr_reader :tool

    define_widget do
      def content
        strong 'Tools:'
        ul do
          li { link_to("Log").action { @tool = Hammer::Component::Developer::Log.new } }
          li { link_to("Inspector Hammer::Core::Base").action { @tool = inspector Hammer::Core::Base } }
          li { link_to("Inspector Object").action { @tool = inspector Object } }
          li { link_to("Inspector Hammer.logger").action { @tool = inspector Hammer.logger } }
          li do
            link_to("Inspector Chat::Model::Room.rooms").action { @tool = inspector Chat::Model::Room.rooms }
          end if defined? Chat::Model::Room
          li { link_to("GC and stats").action { @tool = Hammer::Component::Developer::Gc.new } }
          if defined? Memprof
            li { link_to("Memprof dump all").action { Memprof.dump_all("heap_dump.json") } }
          end
          li { link_to("none").action { @tool = nil } }
        end

        hr

        render tool if tool
      end
    end

  end
end


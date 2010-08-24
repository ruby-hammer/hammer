# encoding: UTF-8

module Hammer::Component::Developer
  class Tools < Hammer::Component::Base

    attr_reader :tool
    changing { attr_writer :tool }
    children :tool

    define_widget do
      css do
        li { list_style 'square' }
      end

      def wrapper_classes
        super << 'container' #<< 'showgrid'
      end

      def content
        h1 'Tools'
        ul do
          li { link_to("Log").action { self.tool = Hammer::Component::Developer::Log.new } }
          li { link_to("Inspector Hammer::Core::Base").action { self.tool = inspector Hammer::Core::Base } }
          li { link_to("Inspector Object").action { self.tool = inspector Object } }
          li { link_to("Inspector Hammer.logger").action { self.tool = inspector Hammer.logger } }
          li do
            link_to("Inspector Chat::Model::Room.rooms").action { self.tool = inspector Chat::Model::Room.rooms }
          end if defined? Chat::Model::Room
          li { link_to("GC and stats").action { self.tool = Hammer::Component::Developer::Gc.new } }
          if defined? Memprof
            li { link_to("Memprof dump all").action { Memprof.dump_all("heap_dump.json") } }
          end
          li { link_to("none").action { self.tool = nil } }
        end

        hr

        render tool if tool
      end
    end

  end
end


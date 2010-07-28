# encoding: UTF-8

module Hammer::Component::Developer
  class Gc < Hammer::Component::Base

    class Widget < Hammer::Widget::Base
      def content
        stats
        gc
      end

      def stats
        h1 'Stats'
        ul do
          classes = [ 
            Hammer::Core::Container,
            Hammer::Core::Context,
            Hammer::Widget::Base,
            Hammer::Component::Base
          ]
          objects = classes.map {|c| [c.to_s,  ObjectSpace.each_object(c) {}] }.sort_by { |c, count| [count, c.to_s] }
          objects.each do |klass, count|
            li "#{klass}: #{count}"
          end
        end
      end

      def gc
        h1 'GC'
        ul do
          li do
            a "GC::Profiler.enable? => #{GC::Profiler.enabled?}", :callback => on(:click) {
              if GC::Profiler.enabled?
                GC::Profiler.disable
                GC::Profiler.clear
              else
                GC::Profiler.enable
              end
            }
          end if Hammer.v19?
          li { a "GC.start", :callback => on(:click) { ObjectSpace.garbage_collect; ObjectSpace.garbage_collect }}
        end

        pre { code GC::Profiler.result } if Hammer.v19?
        pre { code ObjectSpace.count_objects.to_s } if Hammer.v19?
      end
    end


  end
end
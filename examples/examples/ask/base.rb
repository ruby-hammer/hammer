# encoding: UTF-8
module Examples
  module Ask
    class Base < Hammer::Component::Base

      # +numbers+ - answered numbers
      # +counter+ is place where is counter stored or form would been
      attr_reader :numbers, :counter

      after_initialize do
        @numbers = []
      end

      def sum
        numbers.inject {|sum, num| sum + num }
      end

      class Widget < Hammer::Widget::Base

        def content
          strong 'Numbers:'
          if numbers.blank?
            text 'none'
          else
            numbers.each_with_index do |number, index|
              text '+' if index > 0
              a number.to_s, :callback => on(:click) {
                @counter = ask Examples::Ask::Counter, :counter => number do |answer|
                  if answer
                    @numbers.delete_at(index)
                    @numbers.insert(index, answer)
                  end
                  @counter = nil
                end
              }
            end
            #        text component.numbers.join(' + ')
            text " = #{sum}"
          end
          br

          # If counter is set, let's show it
          # if not, let's add link to new one
          if counter
            render counter
          else
            a 'Add Number', :callback => on(:click) {
              # if 'Select Number' is clicked, +counter+ is set and
              # ask-callback is set. Both blocks are evaluated inside
              # the same component.
              @counter = ask Examples::Ask::Counter do |answer|
                if answer
                  @numbers << answer
                end
                @counter = nil
              end
            }
          end
        end
      end

    end
  end
end

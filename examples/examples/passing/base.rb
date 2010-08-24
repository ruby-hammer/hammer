module Examples::Passing
  class Base < Hammer::Component::Base
    define_widget :quickly do
      text 'passing component: '
      link_to("pass").action do
        pass_on ask(Passe.new) {|_| retake_control! }
      end
    end
  end

  class Passe < Hammer::Component::Base
    define_widget :quickly do
      text 'passe component: '
      link_to("retake control").action { answer! }
    end
  end
end
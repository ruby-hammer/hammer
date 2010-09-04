class ActiveSupport::BasicObject
  define_method :instance_eval, Object.instance_method(:instance_eval) unless ::Hammer.v19?
end
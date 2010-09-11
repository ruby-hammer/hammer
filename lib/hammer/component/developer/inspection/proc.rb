module Hammer::Component::Developer::Inspection
  class Proc < Object
    def unpack
      super.push(
        inspector(eval('self', obj.binding), :label => 'Self'),
        inspector(
          eval('local_variables', obj.binding).inject({}) do |hash, var|
            hash[var] = eval(var.to_s, obj.binding)
            hash
          end,
          :label => 'Local variables'
        )
      )
    end
  end
end

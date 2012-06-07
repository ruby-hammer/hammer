class Proc
  #def inspect
  #  super[0..-2] + " self=#{scope.inspect}" +
  #      " local_variables=#{local_variables.inspect}>"
  #end

  def scope
    eval('self', binding)
  end

  def local_variables
    eval('local_variables', binding).inject({}) do |hash, var|
      hash[var] = eval(var.to_s, binding)
      hash
    end
  end
end

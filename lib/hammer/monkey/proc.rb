class Proc
  def inspect
    super[0..-2] + " self=#{eval('self', binding).inspect}" +
        " local_variables=" +
        eval('local_variables', binding).inject({}) do |hash, var|
      hash[var] = eval(var.to_s, binding)
      hash
    end.inspect + ">"
  end
end

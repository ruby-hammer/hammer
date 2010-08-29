# encodes into json without ""
# @example
#   {:abc => JSString("function() {}")}.to_json #=> {"abc":function() {}}
class Hammer::JSString < String
  def encode_json(encoder)
    self.to_s
  end

  def as_json(options = nil)
    self
  end
end
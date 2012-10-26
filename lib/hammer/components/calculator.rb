class Hammer::Components::Calculator < Hammer::Component

  attr_reader :a, :b
  changing do
    attr_writer :a, :b
  end

  def content(b)
    b.h1 "Calculator"
    b.input(:type => 'text', :value => a).action(:value) { |v| self.a = v.to_f }
    b.text ' * '
    b.input(:type => 'text', :value => self.b).action(:value) { |v| self.b = v.to_f }
    b.text " = #{a * self.b}"
  end

  def to_url
    "a:#{a}b:#{b}"
  end

  def from_url(url)
    if url.blank? || url !~ /a:([-\d\.]+)b:([-\d\.]+)/
      self.a = 0
      self.b = 0
    else
      self.a = $1.to_f
      self.b = $2.to_f
    end
  end

end

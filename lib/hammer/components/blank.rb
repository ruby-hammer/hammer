class Hammer::Components::Blank < Hammer::Component

  def content(b)
    b.p "Blank"
  end

  def to_url
    ''
  end

  def from_url(url)
  end

end

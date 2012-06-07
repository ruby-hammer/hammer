class Hammer::AppComponents::Simple < Hammer::AppComponents::Abstract
  attr_reader :root

  def initialize(app, root, options = { })
    super(app, options)
    @root = root
  end

  def content(builder)
    builder.component root
  end

  def to_url
    root.to_url
  end
end
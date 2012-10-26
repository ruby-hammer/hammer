class Hammer::AppComponents::App < Hammer::AppComponents::Abstract
  def initialize(app, options = { })
    super(app, options)
  end

  def content(builder)
    builder.component app.root
  end
end

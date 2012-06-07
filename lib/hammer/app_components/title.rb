class Hammer::AppComponents::Title < Hammer::AppComponents::Abstract
  attr_reader :value
  changing { attr_writer :value }

  def initialize(app, options = { })
    super app, options
    @value = 'Hammer'
  end

  def wrapper_tag
    :title
  end

  def content(builder)
    builder.text value
  end

end

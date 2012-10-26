class Hammer::Apps::App < Hammer::Apps::Abstract

  attr_reader :root, :root_class

  def initialize(context, id, options = { })
    super context, id, options
    @root_class = options[:root_class] || raise(ArgumentError, 'missing :root_class')
    raise(ArgumentError, 'missing :url') unless options.has_key? :url
    from_url options[:url]
  end

  def create_app_component
    Hammer::AppComponents::App.send :new, self
  end

  def to_url
    root.to_url
  end

  def from_url(url)
    @root = root_class.send :new, self, :url => url
  end


end

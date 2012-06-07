class Hammer::AppComponents::Abstract < Hammer::Component
  def wrapper_options(tag)
    super
    tag.app
  end

  def id
    app.id
  end
end
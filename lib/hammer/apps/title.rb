class Hammer::Apps::Title < Hammer::Apps::Abstract

  def create_app_component
    Hammer::AppComponents::Title.send :new, self
  end

  def value
    app_component.value
  end

  def value=(title)
    app_component.value = title
  end

end

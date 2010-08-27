module Hammer::Widget::Blueprint
  def head_content
    super
    blueprint
  end

  def blueprint
    rawtext <<CSSHEADERS
<link rel="stylesheet" href="css/blueprint/screen.css" type="text/css" media="screen, projection">
<link rel="stylesheet" href="css/blueprint/print.css" type="text/css" media="print">
<!--[if lt IE 8]><link rel="stylesheet" href="css/blueprint/ie.css" type="text/css" media="screen, projection"><![endif]-->
CSSHEADERS
  end
end
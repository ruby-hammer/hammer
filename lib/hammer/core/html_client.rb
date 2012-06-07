class Hammer::Core::HtmlClient

  attr_reader :core

  def initialize(core)
    @core = core
  end

  def apps
    @apps ||= begin
      core.container('html_client').create_context.apps
    end
  end

  def id
    'root'
  end

  def scripts
    %w( /socket.io/socket.io.js
        /right/right-src.js
        /hammer/hammer.js
        /hammer/jquery-1.6.1.js
        /hammer/jquery-no_conflict.js
        /hammer/jquery.ba-hashchange.js
        /hammer/callbacks.js)
  end

  def favicon
    '/hammer/hammer.png'
  end

  def render_scripts(builder)
    scripts.each { |path| builder.script :src => path, :type => 'text/javascript' }
  end

  def render_encoding(builder)
    builder.meta :charset => "utf-8"
  end

  def content(b)
    b.html5
    b.html do
      b.head do
        b.render apps['title'], :wrapper
        render_scripts b
        render_encoding b
        b.link :rel => "shortcut icon", :href => favicon
        #if name = core.config.app.project
        #  # TODO better mechanism for loading css
        #  #noinspection RubyArgCount
        #  b.link :href => "css/#{name.underscore}.css", :media => 'all', :rel => 'stylesheet', :type => 'text/css'
        #end
      end

      b.body do
        render_body b
      end
    end
  end

  def render_body b
    apps.each do |id, app|
      next if id == 'title'
      b.render app, :wrapper
    end
  end

end

# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hammer}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Petr Chalupa"]
  s.date = %q{2010-07-28}
  s.description = %q{ruby component based state-full web framework}
  s.email = %q{hammer.framework@gmail.com}
  s.executables = ["hammer-memprof", "hammer-prof", "hammer"]
  s.extra_rdoc_files = [
    "MIT-LICENSE",
     "README.md",
     "README_FULL.md",
     "docs/contribute.md",
     "docs/wave.md"
  ]
  s.files = [
    "examples/config.yml",
     "examples/examples/app_layout.rb",
     "examples/examples/ask/base.rb",
     "examples/examples/ask/counter.rb",
     "examples/examples/base.rb",
     "examples/examples/counter.rb",
     "examples/examples/counters/base.rb",
     "examples/examples/counters/counter.rb",
     "examples/examples/form/base.rb",
     "examples/public/css/basic.css",
     "examples/public/css/chat.css",
     "examples/public/css/developer.css",
     "examples/public/css/ui-lightness/images/ui-anim_basic_16x16.gif",
     "examples/public/css/ui-lightness/images/ui-bg_diagonals-thick_18_b81900_40x40.png",
     "examples/public/css/ui-lightness/images/ui-bg_diagonals-thick_20_666666_40x40.png",
     "examples/public/css/ui-lightness/images/ui-bg_flat_10_000000_40x100.png",
     "examples/public/css/ui-lightness/images/ui-bg_glass_100_f6f6f6_1x400.png",
     "examples/public/css/ui-lightness/images/ui-bg_glass_100_fdf5ce_1x400.png",
     "examples/public/css/ui-lightness/images/ui-bg_glass_65_ffffff_1x400.png",
     "examples/public/css/ui-lightness/images/ui-bg_gloss-wave_35_f6a828_500x100.png",
     "examples/public/css/ui-lightness/images/ui-bg_highlight-soft_100_eeeeee_1x100.png",
     "examples/public/css/ui-lightness/images/ui-bg_highlight-soft_75_ffe45c_1x100.png",
     "examples/public/css/ui-lightness/images/ui-icons_222222_256x240.png",
     "examples/public/css/ui-lightness/images/ui-icons_228ef1_256x240.png",
     "examples/public/css/ui-lightness/images/ui-icons_ef8c08_256x240.png",
     "examples/public/css/ui-lightness/images/ui-icons_ffd27a_256x240.png",
     "examples/public/css/ui-lightness/images/ui-icons_ffffff_256x240.png",
     "examples/public/css/ui-lightness/jquery-ui-1.8.2.custom.css",
     "examples/public/favicon.ico",
     "examples/public/img/loading.gif",
     "examples/public/js/FABridge.js",
     "examples/public/js/WebSocketMain.swf",
     "examples/public/js/chat.js",
     "examples/public/js/hammer.js",
     "examples/public/js/jquery-1.4.2.js",
     "examples/public/js/jquery-1.4.2.min.js",
     "examples/public/js/jquery-ui-1.8.2.custom.min.js",
     "examples/public/js/jquery.ba-hashchange.js",
     "examples/public/js/jquery.ba-hashchange.min.js",
     "examples/public/js/swfobject.js",
     "examples/public/js/web_socket.js",
     "lib/hammer.rb",
     "lib/hammer/component.rb",
     "lib/hammer/component/abstract.rb",
     "lib/hammer/component/answer.rb",
     "lib/hammer/component/base.rb",
     "lib/hammer/component/developer.rb",
     "lib/hammer/component/developer/gc.rb",
     "lib/hammer/component/developer/inspection.rb",
     "lib/hammer/component/developer/inspection/abstract.rb",
     "lib/hammer/component/developer/inspection/array.rb",
     "lib/hammer/component/developer/inspection/class.rb",
     "lib/hammer/component/developer/inspection/hash.rb",
     "lib/hammer/component/developer/inspection/module.rb",
     "lib/hammer/component/developer/inspection/object.rb",
     "lib/hammer/component/developer/inspection/simple.rb",
     "lib/hammer/component/developer/log.rb",
     "lib/hammer/component/developer/tools.rb",
     "lib/hammer/component/form_part.rb",
     "lib/hammer/component/inspection.rb",
     "lib/hammer/component/passing.rb",
     "lib/hammer/component/rendering.rb",
     "lib/hammer/config.rb",
     "lib/hammer/core.rb",
     "lib/hammer/core/action.rb",
     "lib/hammer/core/application.rb",
     "lib/hammer/core/base.rb",
     "lib/hammer/core/common_logger.rb",
     "lib/hammer/core/container.rb",
     "lib/hammer/core/context.rb",
     "lib/hammer/core/fiber_pool.rb",
     "lib/hammer/core/observable.rb",
     "lib/hammer/core/web_socket/connection.rb",
     "lib/hammer/load.rb",
     "lib/hammer/loader.rb",
     "lib/hammer/logger.rb",
     "lib/hammer/runner.rb",
     "lib/hammer/widget.rb",
     "lib/hammer/widget/abstract.rb",
     "lib/hammer/widget/base.rb",
     "lib/hammer/widget/callback.rb",
     "lib/hammer/widget/collection.rb",
     "lib/hammer/widget/component.rb",
     "lib/hammer/widget/form_part.rb",
     "lib/hammer/widget/form_part/abstract.rb",
     "lib/hammer/widget/form_part/input.rb",
     "lib/hammer/widget/form_part/select.rb",
     "lib/hammer/widget/form_part/textarea.rb",
     "lib/hammer/widget/layout.rb",
     "lib/hammer/widget/optionable_collection.rb",
     "lib/hammer/widget/wrapping.rb"
  ]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{ruby component based state-full web framework}
  s.test_files = [
    "spec/hammer/widget/callback_spec.rb",
     "spec/hammer/widget/base_spec.rb",
     "spec/hammer/widget/component_spec.rb",
     "spec/hammer/loader_spec.rb",
     "spec/hammer/component/form_part_spec.rb",
     "spec/hammer/component/developer/inspection/array_spec.rb",
     "spec/hammer/component/developer/inspection/object_spec.rb",
     "spec/hammer/component/base_spec.rb",
     "spec/hammer/core/container_spec.rb",
     "spec/hammer/core/context_spec.rb",
     "spec/hammer/core/observable_spec.rb",
     "spec/hammer/core/application_spec.rb",
     "spec/hammer/core/base_spec.rb",
     "spec/benchmark/rendering_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tzinfo>, [">= 0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0.beta"])
      s.add_runtime_dependency(%q<erector>, [">= 0.8.1"])
      s.add_runtime_dependency(%q<sinatra>, [">= 1.0"])
      s.add_runtime_dependency(%q<thin>, [">= 0"])
      s.add_runtime_dependency(%q<em-websocket>, [">= 0"])
      s.add_runtime_dependency(%q<configliere>, [">= 0"])
      s.add_runtime_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0.beta"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<BlueCloth>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
    else
      s.add_dependency(%q<tzinfo>, [">= 0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 3.0.0.beta"])
      s.add_dependency(%q<erector>, [">= 0.8.1"])
      s.add_dependency(%q<sinatra>, [">= 1.0"])
      s.add_dependency(%q<thin>, [">= 0"])
      s.add_dependency(%q<em-websocket>, [">= 0"])
      s.add_dependency(%q<configliere>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.0.0.beta"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<BlueCloth>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
    end
  else
    s.add_dependency(%q<tzinfo>, [">= 0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 3.0.0.beta"])
    s.add_dependency(%q<erector>, [">= 0.8.1"])
    s.add_dependency(%q<sinatra>, [">= 1.0"])
    s.add_dependency(%q<thin>, [">= 0"])
    s.add_dependency(%q<em-websocket>, [">= 0"])
    s.add_dependency(%q<configliere>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.0.0.beta"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<BlueCloth>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
  end
end


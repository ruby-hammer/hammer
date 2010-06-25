# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in /home/pitr/NetBeansProjects/personal/isy/Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{isy}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Petr Chalupa"]
  s.date = %q{2010-06-25}
  s.description = %q{ruby component based state-full web framework}
  s.extra_rdoc_files = [
    "MIT-LICENSE",
     "README.md",
     "README_FULL.md",
     "docs/contribute.md",
     "docs/discussion.md",
     "docs/name.md",
     "docs/wave.md"
  ]
  s.files = [
    "examples/app.rb",
     "examples/components/ask/base.rb",
     "examples/components/ask/counter.rb",
     "examples/components/counter.rb",
     "examples/components/counters/base.rb",
     "examples/components/counters/counter.rb",
     "examples/components/examples.rb",
     "examples/layouts/app_layout.rb",
     "examples/public/basic.css",
     "examples/public/favicon.ico",
     "examples/public/js/jquery-1.3.2.js",
     "examples/public/js/jquery-1.3.2.min.js",
     "lib/isy.rb",
     "lib/isy/application/base.rb",
     "lib/isy/application/common_logger.rb",
     "lib/isy/component/base.rb",
     "lib/isy/context/action.rb",
     "lib/isy/context/base.rb",
     "lib/isy/context/container.rb",
     "lib/isy/widget/base.rb",
     "lib/isy/widget/collection.rb",
     "lib/isy/widget/inspector.rb",
     "lib/isy/widget/layout.rb",
     "lib/isy/widget/optionable_collection.rb"
  ]
  s.homepage = %q{http://isy-pitr.github.com/isy-playground}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{ruby component based state-full web framework}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<uuid>, [">= 0"])
      s.add_runtime_dependency(%q<tzinfo>, [">= 0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0.beta"])
      s.add_runtime_dependency(%q<erector>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
      s.add_runtime_dependency(%q<thin>, [">= 0"])
      s.add_runtime_dependency(%q<require_all>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0.beta"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<yard-rspec>, [">= 0"])
      s.add_development_dependency(%q<bluecloth>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
    else
      s.add_dependency(%q<uuid>, [">= 0"])
      s.add_dependency(%q<tzinfo>, [">= 0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 3.0.0.beta"])
      s.add_dependency(%q<erector>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<thin>, [">= 0"])
      s.add_dependency(%q<require_all>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.0.0.beta"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<yard-rspec>, [">= 0"])
      s.add_dependency(%q<bluecloth>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
    end
  else
    s.add_dependency(%q<uuid>, [">= 0"])
    s.add_dependency(%q<tzinfo>, [">= 0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 3.0.0.beta"])
    s.add_dependency(%q<erector>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<thin>, [">= 0"])
    s.add_dependency(%q<require_all>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.0.0.beta"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<yard-rspec>, [">= 0"])
    s.add_dependency(%q<bluecloth>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
  end
end

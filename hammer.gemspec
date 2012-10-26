# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hammer"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Petr Chalupa"]
  s.date = "2012-10-16"
  s.description = "ruby component based state-full web framework"
  s.email = "email@pitr.ch"
  s.executables = ["hammer", "hammer-irb", "hammer-memprof", "hammer-prof"]
  s.extra_rdoc_files = [
    "MIT-LICENSE",
    "README.md"
  ]
  s.files = [
    "lib/hammer.rb",
    "lib/hammer/app_components.rb",
    "lib/hammer/app_components/abstract.rb",
    "lib/hammer/app_components/app.rb",
    "lib/hammer/app_components/title.rb",
    "lib/hammer/apps.rb",
    "lib/hammer/apps/abstract.rb",
    "lib/hammer/apps/actions_dispatcher.rb",
    "lib/hammer/apps/app.rb",
    "lib/hammer/apps/scheduler.rb",
    "lib/hammer/apps/title.rb",
    "lib/hammer/builder.rb",
    "lib/hammer/component.rb",
    "lib/hammer/component/actions.rb",
    "lib/hammer/component/state.rb",
    "lib/hammer/component/state_helper.rb",
    "lib/hammer/component/updater.rb",
    "lib/hammer/components.rb",
    "lib/hammer/components/blank.rb",
    "lib/hammer/components/calculator.rb",
    "lib/hammer/components/counters.rb",
    "lib/hammer/components/examples.rb",
    "lib/hammer/config.rb",
    "lib/hammer/core.rb",
    "lib/hammer/core/action.rb",
    "lib/hammer/core/adapters.rb",
    "lib/hammer/core/adapters/abstract.rb",
    "lib/hammer/core/adapters/node_zmq.rb",
    "lib/hammer/core/container.rb",
    "lib/hammer/core/context.rb",
    "lib/hammer/core/fiber_pool.rb",
    "lib/hammer/core/html_client.rb",
    "lib/hammer/core/id_generator.rb",
    "lib/hammer/core/logging.rb",
    "lib/hammer/fiber.rb",
    "lib/hammer/finalizer.rb",
    "lib/hammer/loader.rb",
    "lib/hammer/message.rb",
    "lib/hammer/monkey/basic_object.rb",
    "lib/hammer/monkey/data_objects_em_fiber.rb",
    "lib/hammer/monkey/proc.rb",
    "lib/hammer/monkey/weak_identity_map.rb",
    "lib/hammer/node/server.js",
    "lib/hammer/observable.rb",
    "lib/hammer/observer.rb",
    "lib/hammer/public/hammer/callbacks.js",
    "lib/hammer/public/hammer/hammer.js",
    "lib/hammer/public/hammer/hammer.png",
    "lib/hammer/public/hammer/jquery-1.6.1.js",
    "lib/hammer/public/hammer/jquery-no_conflict.js",
    "lib/hammer/public/hammer/jquery.ba-hashchange.js",
    "lib/hammer/public/right/right-safe-src.js",
    "lib/hammer/public/right/right-safe.js",
    "lib/hammer/public/right/right-safe.js.gz",
    "lib/hammer/public/right/right-src.js",
    "lib/hammer/public/right/right.js",
    "lib/hammer/public/right/right.js.gz",
    "lib/hammer/runner.rb",
    "lib/hammer/runner/node.rb",
    "lib/hammer/utils.rb",
    "lib/hammer/weak.rb"
  ]
  s.homepage = "https://github.com/ruby-hammer/hammer"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "ruby component based state-full web framework"
  s.test_files = ["spec/hammer/component/state_spec.rb", "spec/hammer/core/context/scheduler_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hammer_builder>, [">= 0"])
      s.add_runtime_dependency(%q<hammer>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6.0"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<bluecloth>, ["~> 2.1"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.6"])
      s.add_runtime_dependency(%q<yajl-ruby>, [">= 0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_runtime_dependency(%q<zmq>, [">= 0"])
      s.add_runtime_dependency(%q<hammer_builder>, [">= 0.3.1"])
      s.add_runtime_dependency(%q<configliere>, [">= 0"])
      s.add_runtime_dependency(%q<radix62>, [">= 0"])
      s.add_runtime_dependency(%q<log4r>, [">= 0"])
      s.add_runtime_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<bluecloth>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
    else
      s.add_dependency(%q<hammer_builder>, [">= 0"])
      s.add_dependency(%q<hammer>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.6.0"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<bluecloth>, ["~> 2.1"])
      s.add_dependency(%q<jeweler>, ["~> 1.6"])
      s.add_dependency(%q<rack-test>, ["~> 0.6"])
      s.add_dependency(%q<yajl-ruby>, [">= 0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<zmq>, [">= 0"])
      s.add_dependency(%q<hammer_builder>, [">= 0.3.1"])
      s.add_dependency(%q<configliere>, [">= 0"])
      s.add_dependency(%q<radix62>, [">= 0"])
      s.add_dependency(%q<log4r>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<bluecloth>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
    end
  else
    s.add_dependency(%q<hammer_builder>, [">= 0"])
    s.add_dependency(%q<hammer>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.6.0"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<bluecloth>, ["~> 2.1"])
    s.add_dependency(%q<jeweler>, ["~> 1.6"])
    s.add_dependency(%q<rack-test>, ["~> 0.6"])
    s.add_dependency(%q<yajl-ruby>, [">= 0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<zmq>, [">= 0"])
    s.add_dependency(%q<hammer_builder>, [">= 0.3.1"])
    s.add_dependency(%q<configliere>, [">= 0"])
    s.add_dependency(%q<radix62>, [">= 0"])
    s.add_dependency(%q<log4r>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<bluecloth>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
  end
end


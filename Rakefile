require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "hammer"
    gem.summary     = %Q{ruby component based state-full web framework}
    gem.description = %Q{ruby component based state-full web framework}
    gem.email       = "email@pitr.ch"
    gem.homepage    = "https://github.com/ruby-hammer/hammer"
    gem.authors     = ["Petr Chalupa"]

    gem.add_dependency 'yajl-ruby'
    gem.add_dependency 'i18n'
    gem.add_dependency 'activesupport'
    gem.add_dependency 'eventmachine'
    gem.add_dependency 'zmq'
    gem.add_dependency 'hammer_builder', '>= 0.3.1'
    gem.add_dependency 'configliere'
    gem.add_dependency 'radix62'
    gem.add_dependency 'log4r'
    gem.add_dependency 'bundler'
    #gem.add_dependency 'data_objects'
    #gem.add_dependency 'datamapper'

    gem.add_development_dependency "rspec"
    gem.add_development_dependency "yard"
    gem.add_development_dependency "bluecloth"
    gem.add_development_dependency "jeweler"

    gem.files = FileList['lib/**/*.*'].to_a

    gem.test_files       = FileList["spec/**/*.*"].to_a
    gem.extra_rdoc_files = FileList["README.md", "README_FULL.md", "MIT-LICENSE", 'docs/**/*.*'].to_a

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

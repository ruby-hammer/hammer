# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|

  s.name             = 'hammer-weak'
  s.version          = '0.0.1'
  s.date             = '2013-03-26'
  s.summary          = 'Weak collections'
  s.description      = 'Provides weak Queue, WeakKeyHash (weak key only), WeakHash (weak key and value)'
  s.authors          = ['Petr Chalupa']
  s.email            = 'git@pitr.ch'
  s.homepage         = 'https://github.com/ruby-hammer/hammer'
  #s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.extra_rdoc_files = %w(MIT-LICENSE)
  s.files            = Dir['lib/hammer-weak.rb']
  s.require_paths    = %w(lib)
  s.rubygems_version = '1.8.24'
  s.test_files       = Dir['spec/hammer-weak.rb']

  #{}.each do |gem, version|
  #  s.add_runtime_dependency(gem, [version || '>= 0'])
  #end

  { 'minitest' => nil,
    'turn'     => nil,
    'pry'      => nil,
  }.each do |gem, version|
    s.add_development_dependency(gem, [version || '>= 0'])
  end
end


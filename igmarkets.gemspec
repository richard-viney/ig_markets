$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'ig_markets/version'

Gem::Specification.new do |s|
  s.name        = 'ig_markets'
  s.version     = IGMarkets::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.summary     = 'IG Markets API client'
  s.description = 'IG Markets API client for accessing the IG Markets dealing platform'
  s.homepage    = 'https://github.com/rviney/ig_markets'
  s.author      = 'Richard Viney'
  s.email       = 'richard.viney@gmail.com'
  s.files       = `git ls-files`.split("\n")

  s.required_ruby_version = '>= 2.0'

  s.add_runtime_dependency 'active_attr', '~> 0.8'
  s.add_runtime_dependency 'rest-client', '~> 1.8'

  s.add_development_dependency 'rspec',   '~> 3.3'
  s.add_development_dependency 'rubocop', '~> 0'
end

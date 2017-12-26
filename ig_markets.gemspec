$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'ig_markets/version'

Gem::Specification.new do |s|
  s.name = 'ig_markets'
  s.version = IGMarkets::VERSION
  s.platform = Gem::Platform::RUBY
  s.license = 'MIT'
  s.summary = 'Library and command-line client for accessing the IG Markets dealing platform.'
  s.homepage = 'https://github.com/richard-viney/ig_markets'
  s.author = 'Richard Viney'
  s.email = 'richard.viney@gmail.com'
  s.files = Dir['bin/ig_markets', 'lib/**/*.rb', 'CHANGELOG.md', 'LICENSE.md', 'README.md']
  s.extensions = ['ext/mkrf_conf.rb']
  s.executables = ['ig_markets']

  s.required_ruby_version = '>= 2.2.2'

  s.add_runtime_dependency 'colorize', '~> 0.8'
  s.add_runtime_dependency 'excon', '~> 0.51'
  s.add_runtime_dependency 'lightstreamer', '~> 0.14'
  s.add_runtime_dependency 'pry', '~> 0.10'
  s.add_runtime_dependency 'terminal-table', '~> 1.6'
  s.add_runtime_dependency 'thor', '~> 0.19'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0'
  s.add_development_dependency 'factory_bot', '~> 4.8'
  s.add_development_dependency 'github-markup', '~> 1.4'
  s.add_development_dependency 'redcarpet', '~> 3.3'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'rspec-mocks', '~> 3.5'
  s.add_development_dependency 'rubocop', '~> 0.50'
  s.add_development_dependency 'rubocop-rspec', '~> 1.17'
  s.add_development_dependency 'simplecov', '~> 0.12'
  s.add_development_dependency 'yard', '~> 0.9'
end

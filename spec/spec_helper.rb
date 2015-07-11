require 'bundler/setup'
Bundler.setup

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'ig_markets'

RSpec.configure do |config|
  config.order = :random
end

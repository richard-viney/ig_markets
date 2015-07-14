require 'bundler/setup'
Bundler.setup

require 'support/factory_girl'
require 'support/random_test_order'

require 'codeclimate-test-reporter'
if ENV.key? 'CODECLIMATE_REPO_TOKEN'
  CodeClimate::TestReporter.start
else
  SimpleCov.start
end

require 'ig_markets'

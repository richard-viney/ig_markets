require 'bundler/setup'
Bundler.setup

require 'codeclimate-test-reporter'
if ENV.key? 'CODECLIMATE_REPO_TOKEN'
  CodeClimate::TestReporter.start
else
  SimpleCov.start
end

require 'ig_markets'

require 'support/cli_command_context'
require 'support/dealing_platform_context'
require 'support/factory_girl'
require 'support/random_test_order'

# Specs must always be run with the same time zone because times are reported in the local time zone
ENV['TZ'] = 'UTC'

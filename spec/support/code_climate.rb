require 'codeclimate-test-reporter'

if ENV.key? 'CODECLIMATE_REPO_TOKEN'
  CodeClimate::TestReporter.start
else
  SimpleCov.start
end

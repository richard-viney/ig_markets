RSpec.shared_context 'cli_command', :cli_command do
  include_context 'dealing_platform'

  before do
    dealing_platform_model IGMarkets::CLI::Main

    allow(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end
end

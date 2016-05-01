RSpec.shared_context 'cli_command' do
  include_context 'dealing_platform'

  before do
    IGMarkets::CLI::Main.instance_variable_set :@dealing_platform, dealing_platform

    allow(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end
end

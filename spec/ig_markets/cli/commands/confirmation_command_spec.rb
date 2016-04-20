describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints a deal confirmation' do
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli.confirmation 'ref'
  end
end

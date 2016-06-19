describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  it 'searches for markets' do
    markets = [build(:market_overview, net_change: -1)]

    expect(dealing_platform.markets).to receive(:search).with('EURUSD').and_return(markets)

    expect { cli.search 'EURUSD' }.to output("#{IGMarkets::CLI::MarketOverviewsTable.new markets}\n").to_stdout
  end

  it 'searches for markets with a specific type' do
    markets = [build(:market_overview, net_change: -1), build(:market_overview, instrument_type: 'SHARES')]

    expect(dealing_platform.markets).to receive(:search).with('EURUSD').and_return(markets)

    expect do
      cli(type: 'currencies').search 'EURUSD'
    end.to output("#{IGMarkets::CLI::MarketOverviewsTable.new markets[0]}\n").to_stdout
  end
end

describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  let(:market) do
    attributes = {
      dealing_rules: build(:market_dealing_rules),
      instrument: build(:instrument),
      snapshot: build(:market_snapshot)
    }

    dealing_platform.instantiate_models IGMarkets::Market, attributes
  end

  before do
    expect(dealing_platform.markets).to receive(:[]).with('A').and_return(market)
  end

  it 'reports an error on invalid arguments' do
    expect { cli(epic: 'A').prices }.to raise_error(ArgumentError)
  end

  it 'lists recent prices' do
    historical_price_result = build :historical_price_result

    expect(market).to receive(:historical_prices).with(resolution: :day, number: 1).and_return(historical_price_result)

    expect do
      cli(epic: 'A', resolution: :day, number: 1).prices
    end.to output(<<-END
#{IGMarkets::CLI::HistoricalPriceResultSnapshotsTable.new historical_price_result.prices, title: 'Prices for A'}

Allowance: 5000
Remaining: 4990
END
                 ).to_stdout
  end

  it 'lists prices in a date range' do
    historical_price_result = build :historical_price_result

    options = {
      resolution: :day,
      from: Time.new(2014, 1, 2, 3, 4, 5, '+00:00'),
      to: Time.new(2014, 2, 3, 4, 5, 6, '+00:00')
    }

    expect(market).to receive(:historical_prices).with(options).and_return(historical_price_result)

    expect do
      cli(epic: 'A', resolution: :day, from: '2014-01-02T03:04:05+00:00', to: '2014-02-03T04:05:06+00:00').prices
    end.to output(<<-END
#{IGMarkets::CLI::HistoricalPriceResultSnapshotsTable.new historical_price_result.prices, title: 'Prices for A'}

Allowance: 5000
Remaining: 4990
END
                 ).to_stdout
  end
end

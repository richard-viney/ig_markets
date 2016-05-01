describe IGMarkets::Market do
  include_context 'dealing_platform'

  let(:market) { with_dealing_platform build(:market) }

  it 'returns a specified number of historical prices' do
    historical_price_results = [build(:historical_price_result)]

    expect(session).to receive(:get)
      .with('prices/ABCDEF?resolution=DAY&max=5', IGMarkets::API_V3)
      .and_return(historical_price_results)

    expect(market.historical_prices(resolution: :day, number: 5)).to eq(historical_price_results)
  end

  it 'returns historical prices from a date range' do
    from_time = Time.new 2014, 1, 2, 3, 4, 5, '+00:00'
    to_time = Time.new 2014, 2, 3, 4, 5, 6, '+00:00'

    historical_price_results = [build(:historical_price_result)]

    expect(session).to receive(:get)
      .with('prices/ABCDEF?resolution=DAY&from=2014-01-02T03:04:05&to=2014-02-03T04:05:06', IGMarkets::API_V3)
      .and_return(historical_price_results)

    result = market.historical_prices resolution: :day, from: from_time, to: to_time
    expect(result).to eq(historical_price_results)
  end

  it 'raises when querying historical prices with invalid options' do
    [
      {},
      { resolution: :day },
      { resolution: :day, from: Time.now }
    ].each do |options|
      expect { market.historical_prices options }.to raise_error(ArgumentError)
    end
  end
end

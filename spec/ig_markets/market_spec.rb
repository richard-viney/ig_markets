describe IGMarkets::Market, :dealing_platform do
  let(:market) { dealing_platform_model build(:market) }

  it 'reloads itself' do
    expect(dealing_platform.markets).to receive(:[]).with('CS.D.EURUSD.CFD.IP').twice.and_return(market)

    market_copy = dealing_platform.markets['CS.D.EURUSD.CFD.IP'].dup
    market_copy.dealing_rules = nil
    market_copy.reload

    expect(market_copy.dealing_rules).to eq(market.dealing_rules)
  end

  it 'retrieves a specified number of historical prices' do
    historical_price_results = [build(:historical_price_result)]

    expect(session).to receive(:get)
      .with('prices/CS.D.EURUSD.CFD.IP?resolution=DAY&max=5', IGMarkets::API_V3)
      .and_return(historical_price_results)

    expect(market.historical_prices(resolution: :day, number: 5)).to eq(historical_price_results)
  end

  it 'retrieves historical prices in a date range' do
    from_time = Time.new 2014, 1, 2, 3, 4, 5, '+00:00'
    to_time = Time.new 2014, 2, 3, 4, 5, 6, '+00:00'

    historical_price_results = [build(:historical_price_result)]

    url = 'prices/CS.D.EURUSD.CFD.IP?resolution=DAY&from=2014-01-02T03:04:05&to=2014-02-03T04:05:06'

    expect(session).to receive(:get).with(url, IGMarkets::API_V3).and_return(historical_price_results)

    result = market.historical_prices resolution: :day, from: from_time, to: to_time
    expect(result).to eq(historical_price_results)
  end

  it 'raises when querying historical prices with invalid options' do
    expect { market.historical_prices({}) }.to raise_error(ArgumentError, 'resolution is invalid')

    expect { market.historical_prices resolution: :day }
      .to raise_error(ArgumentError, 'options must specify either :number or :from and :to')

    expect { market.historical_prices resolution: :day, from: Time.now }
      .to raise_error(ArgumentError, 'options must specify either :number or :from and :to')
  end
end

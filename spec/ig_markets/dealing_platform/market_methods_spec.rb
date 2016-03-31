describe IGMarkets::DealingPlatform::MarketMethods do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'can retrieve the market hierarchy root' do
    get_result = {
      markets: [build(:market_overview)],
      nodes: [build(:market_hierarchy_node)]
    }

    expect(session).to receive(:get).with('marketnavigation', IGMarkets::API_VERSION_1).and_return(get_result)
    expect(platform.markets.hierarchy).to eq(get_result)
  end

  it 'can retrieve a market hierarchy node' do
    get_result = { markets: nil, nodes: nil }

    expect(session).to receive(:get).with('marketnavigation/1', IGMarkets::API_VERSION_1).and_return(get_result)
    expect(platform.markets.hierarchy(1)).to eq(markets: [], nodes: [])
  end

  it 'can retrieve a market from an epic' do
    get_result = {
      market_details: [{
        dealing_rules: build(:market_dealing_rules),
        instrument: build(:instrument),
        snapshot: build(:market_snapshot)
      }]
    }

    expect(session).to receive(:get).with('markets?epics=ABCDEF', IGMarkets::API_VERSION_2).and_return(get_result)
    expect(platform.markets['ABCDEF']).to eq(IGMarkets::Market.from(get_result[:market_details])[0])
  end

  it 'can search for markets' do
    markets = [build(:market_overview)]

    expect(session).to receive(:get)
      .with('markets?searchTerm=USD', IGMarkets::API_VERSION_1)
      .and_return(markets: markets)

    expect(platform.markets.search('USD')).to eq(markets)
  end

  it 'can retrieve a specified number of historical prices for a market' do
    markets_get_result = {
      market_details: [{
        dealing_rules: build(:market_dealing_rules),
        instrument: build(:instrument),
        snapshot: build(:market_snapshot)
      }]
    }

    prices_get_result = {
      allowance: build(:historical_price_data_allowance),
      instrument_type: :currencies,
      prices: [build(:historical_price_snapshot), build(:historical_price_snapshot)]
    }

    expect(session).to receive(:get)
      .with('markets?epics=ABCDEF', IGMarkets::API_VERSION_2)
      .and_return(markets_get_result)

    expect(session).to receive(:get)
      .with('prices/ABCDEF/DAY/5', IGMarkets::API_VERSION_2)
      .and_return(prices_get_result)

    expect(platform.markets['ABCDEF'].recent_prices(:day, 5)).to eq(prices_get_result)
  end

  it 'can retrieve a date range of historical prices for a market' do
    from_date = DateTime.new 2014, 1, 2, 3, 4, 5
    to_date = DateTime.new 2014, 2, 3, 4, 5, 6

    markets_get_result = {
      market_details: [{
        dealing_rules: build(:market_dealing_rules),
        instrument: build(:instrument),
        snapshot: build(:market_snapshot)
      }]
    }

    prices_get_result = {
      allowance: build(:historical_price_data_allowance),
      instrument_type: :currencies,
      prices: [build(:historical_price_snapshot), build(:historical_price_snapshot)]
    }

    expect(session).to receive(:get)
      .with('markets?epics=ABCDEF', IGMarkets::API_VERSION_2)
      .and_return(markets_get_result)

    expect(session).to receive(:get)
      .with('prices/ABCDEF/DAY/2014-01-02 03:04:05/2014-02-03 04:05:06', IGMarkets::API_VERSION_2)
      .and_return(prices_get_result)

    expect(platform.markets['ABCDEF'].prices_in_date_range(:day, from_date, to_date)).to eq(prices_get_result)
  end
end

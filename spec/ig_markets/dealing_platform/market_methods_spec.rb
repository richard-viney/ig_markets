describe IGMarkets::DealingPlatform::MarketMethods do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'can retrieve the market hierarchy root' do
    result = build :market_hierarchy_result

    expect(session).to receive(:get).with('marketnavigation', IGMarkets::API_V1).and_return(result)
    expect(platform.markets.hierarchy).to eq(result)
  end

  it 'can retrieve a market hierarchy node' do
    result = build :market_hierarchy_result

    expect(session).to receive(:get).with('marketnavigation/1', IGMarkets::API_V1).and_return(result)
    expect(platform.markets.hierarchy(1)).to eq(result)
  end

  it 'can retrieve a market from an EPIC' do
    get_result = {
      market_details: [{
        dealing_rules: build(:market_dealing_rules),
        instrument: build(:instrument),
        snapshot: build(:market_snapshot)
      }]
    }

    expect(session).to receive(:get).with('markets?epics=ABCDEF', IGMarkets::API_V2).and_return(get_result)
    expect(platform.markets['ABCDEF']).to eq(IGMarkets::Market.from(get_result[:market_details])[0])
  end

  it 'can search for markets' do
    markets = [build(:market_overview)]

    expect(session).to receive(:get).with('markets?searchTerm=USD', IGMarkets::API_V1).and_return(markets: markets)
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

    historical_price_result = build :historical_price_result

    expect(session).to receive(:get).with('markets?epics=ABCDEF', IGMarkets::API_V2).and_return(markets_get_result)
    expect(session).to receive(:get).with('prices/ABCDEF/DAY/5', IGMarkets::API_V2).and_return(historical_price_result)
    expect(platform.markets['ABCDEF'].recent_prices(:day, 5)).to eq(historical_price_result)
  end

  it 'can retrieve a date range of historical prices for a market' do
    from_time = Time.new 2014, 1, 2, 3, 4, 5
    to_time = Time.new 2014, 2, 3, 4, 5, 6

    markets_get_result = {
      market_details: [{
        dealing_rules: build(:market_dealing_rules),
        instrument: build(:instrument),
        snapshot: build(:market_snapshot)
      }]
    }

    historical_price_result = build :historical_price_result

    expect(session).to receive(:get).with('markets?epics=ABCDEF', IGMarkets::API_V2).and_return(markets_get_result)
    expect(session).to receive(:get)
      .with('prices/ABCDEF/DAY/2014-01-02T03:04:05/2014-02-03T04:05:06', IGMarkets::API_V2)
      .and_return(historical_price_result)

    expect(platform.markets['ABCDEF'].prices_in_date_range(:day, from_time, to_time)).to eq(historical_price_result)
  end
end

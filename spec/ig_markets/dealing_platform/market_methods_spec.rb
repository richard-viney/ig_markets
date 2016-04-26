describe IGMarkets::DealingPlatform::MarketMethods do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'can retrieve the market hierarchy root' do
    result = build :market_hierarchy_result

    expect(session).to receive(:get).with('marketnavigation').and_return(result)
    expect(platform.markets.hierarchy).to eq(result)
  end

  it 'can retrieve a market hierarchy node' do
    result = build :market_hierarchy_result

    expect(session).to receive(:get).with('marketnavigation/1').and_return(result)
    expect(platform.markets.hierarchy(1)).to eq(result)
  end

  let(:markets_get_result) do
    {
      market_details: [{
        dealing_rules: build(:market_dealing_rules),
        instrument: build(:instrument, dealing_platform: platform),
        snapshot: build(:market_snapshot)
      }]
    }
  end

  it 'can retrieve a market from an EPIC' do
    result = platform.instantiate_models IGMarkets::Market, markets_get_result[:market_details]

    expect(session).to receive(:get).with('markets?epics=ABCDEF', IGMarkets::API_V2).and_return(markets_get_result)
    expect(platform.markets['ABCDEF']).to eq(result.first)
  end

  it 'can search for markets' do
    markets = [build(:market_overview)]

    expect(session).to receive(:get).with('markets?searchTerm=USD').and_return(markets: markets)
    expect(platform.markets.search('USD')).to eq(markets)
  end

  it 'can retrieve a specified number of historical prices for a market' do
    historical_price_results = [build(:historical_price_result, dealing_platform: platform)]

    expect(session).to receive(:get).with('markets?epics=ABCDEF', IGMarkets::API_V2).and_return(markets_get_result)
    expect(session).to receive(:get).with('prices/ABCDEF/DAY/5', IGMarkets::API_V2).and_return(historical_price_results)
    expect(platform.markets['ABCDEF'].recent_prices(:day, 5)).to eq(historical_price_results)
  end

  it 'can retrieve a date range of historical prices for a market' do
    from_time = Time.new 2014, 1, 2, 3, 4, 5, '+00:00'
    to_time = Time.new 2014, 2, 3, 4, 5, 6, '+00:00'

    historical_price_results = [build(:historical_price_result, dealing_platform: platform)]

    expect(session).to receive(:get).with('markets?epics=ABCDEF', IGMarkets::API_V2).and_return(markets_get_result)
    expect(session).to receive(:get)
      .with('prices/ABCDEF/DAY/2014-01-02 03:04:05/2014-02-03 04:05:06', IGMarkets::API_V2)
      .and_return(historical_price_results)

    expect(platform.markets['ABCDEF'].prices_in_date_range(:day, from_time, to_time)).to eq(historical_price_results)
  end
end

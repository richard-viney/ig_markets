describe IGMarkets::DealingPlatform::MarketMethods, :dealing_platform do
  let(:markets_get_result) do
    {
      market_details: [{
        dealing_rules: build(:market_dealing_rules),
        instrument: build(:instrument),
        snapshot: build(:market_snapshot)
      }]
    }
  end

  it 'retrieves the market hierarchy root' do
    result = build :market_hierarchy_result

    expect(session).to receive(:get).with('marketnavigation').and_return(result)
    expect(dealing_platform.markets.hierarchy).to eq(result)
  end

  it 'retrieves a market hierarchy node' do
    result = build :market_hierarchy_result

    expect(session).to receive(:get).with('marketnavigation/1').and_return(result)
    expect(dealing_platform.markets.hierarchy(1)).to eq(result)
  end

  it 'retrieves a market from an EPIC' do
    result = dealing_platform.instantiate_models IGMarkets::Market, markets_get_result[:market_details]

    expect(session).to receive(:get).with('markets?epics=ABCDEF', IGMarkets::API_V2).and_return(markets_get_result)
    expect(dealing_platform.markets['ABCDEF']).to eq(result.first)
  end

  it 'raises on retrieving an invalid EPIC' do
    expect { dealing_platform.markets['ABC'] }.to raise_error(ArgumentError, 'invalid EPIC: ABC')
  end

  it 'retrieves multiple markets from their EPICs in a single call' do
    fifty_markets = { market_details: markets_get_result[:market_details] * 50 }
    ten_markets = { market_details: markets_get_result[:market_details] * 10 }

    epics = Array.new(60) { ('a'..'z').to_a.sample(6).join.upcase }

    expect(session).to receive(:get)
      .with("markets?epics=#{epics[0...50].join ','}", IGMarkets::API_V2)
      .and_return(fifty_markets)

    expect(session).to receive(:get)
      .with("markets?epics=#{epics[50..-1].join ','}", IGMarkets::API_V2)
      .and_return(ten_markets)

    expect(dealing_platform.markets.find(epics).size).to eq(60)
  end

  it 'searches for markets' do
    markets = [build(:market_overview)]

    expect(session).to receive(:get).with('markets?searchTerm=USD').and_return(markets: markets)
    expect(dealing_platform.markets.search('USD')).to eq(markets)
  end
end

describe IGMarkets::DealingPlatform do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'has a valid session' do
    expect(IGMarkets::DealingPlatform.new.session).to be_an_instance_of(IGMarkets::Session)
  end

  it 'can sign in' do
    expect(session).to receive(:sign_in).and_return({})

    expect(platform.sign_in('username', 'password', 'api_key', :production)).to eq({})

    expect(session.username).to eq('username')
    expect(session.password).to eq('password')
    expect(session.api_key).to eq('api_key')
    expect(session.platform).to eq(:production)
  end

  it 'can sign out' do
    expect(session).to receive(:sign_out).and_return(nil)
    expect(platform.sign_out).to eq(nil)
  end

  it 'can retrieve accounts' do
    accounts = [build(:account)]

    expect(session).to receive(:get)
      .with('accounts', IGMarkets::API_VERSION_1)
      .and_return(accounts: accounts.map(&:attributes))

    expect(platform.accounts).to eq(accounts)
  end

  it 'can retrieve activities in a date range' do
    activities = [build(:account_activity)]

    expect(session).to receive(:get)
      .with('history/activity/20-05-2014/27-10-2014', IGMarkets::API_VERSION_1)
      .and_return(activities: activities.map(&:attributes))

    expect(platform.activities_in_date_range(Date.new(2014, 5, 20), Date.new(2014, 10, 27))).to eq(activities)
  end

  it 'can retrieve activities in recent period' do
    activities = [build(:account_activity)]

    expect(session).to receive(:get)
      .with('history/activity/1000', IGMarkets::API_VERSION_1)
      .and_return(activities: activities.map(&:attributes))

    expect(platform.activities_in_recent_period(1000)).to eq(activities)
  end

  it 'can retrieve transactions in a date range' do
    transactions = [build(:transaction)]

    expect(session).to receive(:get)
      .with('history/transactions/ALL/20-05-2014/27-10-2014', IGMarkets::API_VERSION_1)
      .and_return(transactions: transactions.map(&:attributes))

    expect(platform.transactions_in_date_range(Date.new(2014, 5, 20), Date.new(2014, 10, 27), :all)).to eq(transactions)
  end

  it 'can retrieve transactions in recent period' do
    transactions = [build(:transaction)]

    expect(session).to receive(:get)
      .with('history/transactions/DEPOSIT/1000', IGMarkets::API_VERSION_1)
      .and_return(transactions: transactions.map(&:attributes))

    expect(platform.transactions_in_recent_period(1000, :deposit)).to eq(transactions)
  end

  it 'can retrieve a deal confirmation' do
    deal_confirmation = build :deal_confirmation

    get_result = deal_confirmation.attributes

    expect(session).to receive(:get).with('confirms/deal_id', IGMarkets::API_VERSION_1).and_return(get_result)
    expect(platform.deal_confirmation('deal_id')).to eq(deal_confirmation)
  end

  it 'can retrieve the current positions' do
    positions = [build(:position)]

    get_result = {
      positions: positions.map(&:attributes).map do |a|
        { market: a[:market], position: a }
      end
    }

    expect(session).to receive(:get).with('positions', IGMarkets::API_VERSION_2).and_return(get_result)
    expect(platform.positions).to eq(positions)
  end

  it 'can retrieve a single position' do
    position = build :position

    expect(session).to receive(:get)
      .with("positions/#{position.deal_id}", IGMarkets::API_VERSION_2)
      .and_return(position: position.attributes, market: position.market)

    expect(platform.position(position.deal_id)).to eq(position)
  end

  it 'can retrieve the current sprint market positions' do
    positions = [build(:sprint_market_position)]

    expect(session).to receive(:get)
      .with('positions/sprintmarkets', IGMarkets::API_VERSION_1)
      .and_return(sprint_market_positions: positions.map(&:attributes))

    expect(platform.sprint_market_positions).to eq(positions)
  end

  it 'can retrieve the current working orders' do
    orders = [build(:working_order)]

    get_result = {
      working_orders: orders.map(&:attributes).map do |a|
        { market_data: a[:market], working_order_data: a }
      end
    }

    expect(session).to receive(:get).with('workingorders', IGMarkets::API_VERSION_2).and_return(get_result)
    expect(platform.working_orders).to eq(orders)
  end

  it 'can retrieve the market hierarchy root' do
    markets = [build(:market)]
    nodes = [build(:market_hierarchy_node)]

    get_result = {
      markets: markets.map(&:attributes),
      nodes: nodes.map(&:attributes)
    }

    expect(session).to receive(:get).with('marketnavigation', IGMarkets::API_VERSION_1).and_return(get_result)
    expect(platform.market_hierarchy).to eq(markets: markets, nodes: nodes)
  end

  it 'can retrieve an empty market hierarchy node' do
    get_result = { markets: nil, nodes: nil }

    expect(session).to receive(:get).with('marketnavigation/1', IGMarkets::API_VERSION_1).and_return(get_result)
    expect(platform.market_hierarchy(1)).to eq(markets: [], nodes: [])
  end

  it 'can retrieve a market from an epic' do
    dealing_rules = {
      market_order_preference: 'AVAILABLE_DEFAULT_ON',
      trailing_stops_preference: 'AVAILABLE',
      max_stop_or_limit_distance: build(:dealing_rule),
      min_controlled_risk_stop_distance: build(:dealing_rule),
      min_deal_size: build(:dealing_rule),
      min_normal_stop_or_limit_distance: build(:dealing_rule),
      min_step_distance: build(:dealing_rule)
    }
    instrument = build :instrument
    snapshot = build :market_snapshot

    get_result = {
      market_details: [{
        dealing_rules: dealing_rules.each_with_object({}) do |(k, v), new_rules|
          new_rules[k] = v.is_a?(IGMarkets::DealingRule) ? v.attributes : v
        end,
        instrument: instrument.attributes,
        snapshot: snapshot.attributes
      }]
    }

    expect(session).to receive(:get).with('markets?epics=ABCDEF', IGMarkets::API_VERSION_1).and_return(get_result)
    expect(platform.market('ABCDEF')).to eq(dealing_rules: dealing_rules, instrument: instrument, snapshot: snapshot)
  end

  it 'can search for markets' do
    markets = [build(:market)]

    expect(session).to receive(:get)
      .with('markets?searchTerm=USD', IGMarkets::API_VERSION_1)
      .and_return(markets: markets.map(&:attributes))

    expect(platform.market_search('USD')).to eq(markets)
  end

  it 'can retrieve a specified number of historical prices for an epic' do
    allowance = build :historical_price_data_allowance
    type = 'SHARES'
    prices = [build(:historical_price_snapshot), build(:historical_price_snapshot)]

    get_result = {
      allowance: allowance.attributes,
      instrument_type: type,
      prices: prices.map(&:attributes)
    }

    expect(session).to receive(:get).with('prices/ABCDEF/DAY/5', IGMarkets::API_VERSION_2).and_return(get_result)
    expect(platform.prices('ABCDEF', :day, 5)).to eq(allowance: allowance, instrument_type: type, prices: prices)
  end

  it 'can retrieve a date range of historical prices for an epic' do
    from_date = DateTime.new(2014, 1, 2, 3, 4, 5)
    to_date = DateTime.new(2014, 2, 3, 4, 5, 6)

    allowance = build :historical_price_data_allowance
    type = 'SHARES'
    prices = [build(:historical_price_snapshot), build(:historical_price_snapshot)]

    get_result = {
      allowance: allowance.attributes,
      instrument_type: type,
      prices: prices.map(&:attributes)
    }

    expect(session).to receive(:get)
      .with('prices/ABCDEF/DAY/2014-01-02 03:04:05/2014-02-03 04:05:06', IGMarkets::API_VERSION_2)
      .and_return(get_result)

    expect(platform.prices_in_date_range('ABCDEF', :day, from_date, to_date))
      .to eq(allowance: allowance, instrument_type: type, prices: prices)
  end

  it 'can retrieve the watchlists' do
    watchlists = [build(:watchlist)]

    expect(session).to receive(:get)
      .with('watchlists', IGMarkets::API_VERSION_1)
      .and_return(watchlists: watchlists.map(&:attributes))

    expect(platform.watchlists).to eq(watchlists)
  end

  it 'can retrieve the markets for a watchlist' do
    markets = [build(:market)]

    expect(session).to receive(:get)
      .with('watchlists/1', IGMarkets::API_VERSION_1)
      .and_return(markets: markets.map(&:attributes))

    expect(platform.watchlist_markets('1')).to eq(markets)
  end

  it 'can retrieve the client sentiment for a market' do
    client_sentiment = build :client_sentiment

    expect(session).to receive(:get)
      .with('clientsentiment/1', IGMarkets::API_VERSION_1)
      .and_return(client_sentiment.attributes)

    expect(platform.client_sentiment('1')).to eq(client_sentiment)
  end

  it 'can retrieve the related client sentiments for a market' do
    client_sentiments = [build(:client_sentiment), build(:client_sentiment)]

    expect(session).to receive(:get)
      .with('clientsentiment/related/1', IGMarkets::API_VERSION_1)
      .and_return(client_sentiments: client_sentiments.map(&:attributes))

    expect(platform.client_sentiment_related('1')).to eq(client_sentiments)
  end

  it 'can retrieve the current applications' do
    applications = [build(:application)]

    expect(session).to receive(:get)
      .with('operations/application', IGMarkets::API_VERSION_1)
      .and_return(applications.map(&:attributes))

    expect(platform.applications).to eq(applications)
  end
end

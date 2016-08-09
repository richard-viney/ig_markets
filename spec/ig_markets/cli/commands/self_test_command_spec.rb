describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  it 'performs a self test' do
    expect(session).to receive(:platform).and_return(:demo)

    # Markets

    eur_usd = build :market

    expect(dealing_platform.markets).to receive(:hierarchy).with('264134').and_return([build(:market_hierarchy_result)])
    expect(dealing_platform.markets).to receive(:search).with('EURUSD').and_return([build(:market_overview)])
    expect(dealing_platform.markets).to receive(:find).with('CS.D.EURUSD.CFD.IP').and_return([eur_usd])
    expect(dealing_platform.markets).to receive(:find).with('FM.D.EURUSD24.EURUSD24.IP').and_return([build(:market)])
    expect(eur_usd).to receive(:historical_prices).with(resolution: :hour, number: 1).and_return([])

    # Positions

    position = dealing_platform_model build(:position)

    expect(dealing_platform.positions).to receive(:create).and_return('ref')
    expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(build(:deal_confirmation))
    expect(dealing_platform.positions).to receive(:[]).with('DEAL').and_return(position)

    expect(position).to receive(:update).and_return('ref')
    expect(dealing_platform.positions).to receive(:[]).with('DEAL')
      .and_return(build(:position, stop_level: position.level - 0.01))

    expect(position).to receive(:close).and_return('ref')
    expect(dealing_platform.positions).to receive(:[]).with('DEAL').and_return(nil)

    # Sprint market positions

    sprint_market_position = build :sprint_market_position

    expect(dealing_platform.sprint_market_positions).to receive(:create).and_return('ref')
    expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(sprint_market_position)
    expect(dealing_platform.sprint_market_positions).to receive(:[]).with('DEAL').and_return(sprint_market_position)

    # Working orders

    working_order = dealing_platform_model build(:working_order)

    expect(dealing_platform.working_orders).to receive(:create).and_return('ref')
    expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(build(:deal_confirmation))
    expect(dealing_platform.working_orders).to receive(:[]).with('DEAL').twice.and_return(working_order)

    expect(working_order).to receive(:update).and_return('ref')
    expect(dealing_platform.working_orders).to receive(:[]).with('DEAL')
      .and_return(build(:working_order, order_level: 99))

    expect(working_order).to receive(:delete).and_return('ref')
    expect(dealing_platform.working_orders).to receive(:[]).with('DEAL').and_return(nil)

    # Watchlists

    watchlist = build :watchlist

    expect(dealing_platform.watchlists).to receive(:create).and_return(watchlist)
    expect(dealing_platform.watchlists).to receive(:[]).with('2547731').and_return(watchlist)
    expect(watchlist).to receive(:markets).and_return([build(:market)])
    expect(watchlist).to receive(:add_market).with('CS.D.EURUSD.CFD.IP')
    expect(watchlist).to receive(:remove_market).with('CS.D.EURUSD.CFD.IP')
    expect(watchlist).to receive(:delete)
    expect(dealing_platform.watchlists).to receive(:[]).and_return(nil)

    # Client sentiment

    client_sentiment = build :client_sentiment

    expect(dealing_platform.client_sentiment).to receive(:[]).with('EURUSD').and_return(client_sentiment)
    expect(client_sentiment).to receive(:related_sentiments).and_return(build(:client_sentiment))

    # Accounts

    expect(dealing_platform.account).to receive(:all).and_return([build(:account)])
    expect(dealing_platform.account).to receive(:activities).and_return([build(:activity)])
    expect(dealing_platform.account).to receive(:transactions).and_return([build(:transaction)])

    # Applications

    expect(dealing_platform).to receive(:applications).and_return([build(:application)])

    # Streaming

    expect(dealing_platform.streaming).to receive(:connect)
    expect(dealing_platform.streaming).to receive(:build_accounts_subscription).and_return(1)
    expect(dealing_platform.streaming).to receive(:build_markets_subscription).and_return(2)
    expect(dealing_platform.streaming).to receive(:build_trades_subscription).and_return(3)
    expect(dealing_platform.streaming).to receive(:start_subscriptions).with([1, 2, 3], snapshot: true)
    expect(dealing_platform.streaming).to receive(:pop_data).exactly(10).times
    expect(dealing_platform.streaming).to receive(:disconnect).twice

    cli.self_test
  end
end

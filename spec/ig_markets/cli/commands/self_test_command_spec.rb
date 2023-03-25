describe IGMarkets::CLI::Main, :cli_command do
  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  it 'performs a self test' do
    expect(session).to receive(:platform).and_return(:demo)

    # Markets

    eur_usd = build(:market)

    expect(dealing_platform.markets).to receive(:hierarchy).with('264134').and_return([build(:market_hierarchy_result)])
    expect(dealing_platform.markets).to receive(:search).with('EURUSD').and_return([build(:market_overview)])
    expect(dealing_platform.markets).to receive(:find).with('CS.D.EURUSD.CFD.IP').and_return([eur_usd])
    expect(dealing_platform.markets).to receive(:find).with('FM.D.EURUSD24.EURUSD24.IP').and_return([build(:market)])
    expect(eur_usd).to receive(:historical_prices).with(resolution: :hour, number: 1).and_return([])

    # Positions

    position = dealing_platform_model build(:position)

    expect(dealing_platform.positions).to receive(:create).and_return('reference')
    expect(dealing_platform).to receive(:deal_confirmation).with('reference').and_return(build(:deal_confirmation))
    expect(dealing_platform.positions).to receive(:[]).with('DEAL').and_return(position)

    expect(position).to receive(:update).and_return('reference')
    expect(dealing_platform.positions)
      .to receive(:[])
      .with('DEAL')
      .and_return(build(:position, stop_level: position.level - 0.01))

    expect(position).to receive(:close).and_return('reference')
    expect(dealing_platform.positions).to receive(:[]).with('DEAL').and_return(nil)

    # Working orders

    working_order = dealing_platform_model build(:working_order)

    expect(dealing_platform.working_orders).to receive(:create).and_return('reference')
    expect(dealing_platform).to receive(:deal_confirmation).with('reference').and_return(build(:deal_confirmation))
    expect(dealing_platform.working_orders).to receive(:[]).with('DEAL').twice.and_return(working_order)

    expect(working_order).to receive(:update).and_return('reference')
    expect(dealing_platform.working_orders)
      .to receive(:[])
      .with('DEAL')
      .and_return(build(:working_order, order_level: 99))

    expect(working_order).to receive(:delete).and_return('reference')
    expect(dealing_platform.working_orders).to receive(:[]).with('DEAL').and_return(nil)

    # Watchlists

    watchlist = build(:watchlist)

    expect(dealing_platform.watchlists).to receive(:create).and_return(watchlist)
    expect(dealing_platform.watchlists).to receive(:[]).with('2547731').and_return(watchlist)
    expect(watchlist).to receive(:markets).and_return([build(:market)])
    expect(watchlist).to receive(:add_market).with('CS.D.EURUSD.CFD.IP')
    expect(watchlist).to receive(:remove_market).with('CS.D.EURUSD.CFD.IP')
    expect(watchlist).to receive(:delete)
    expect(dealing_platform.watchlists).to receive(:[]).and_return(nil)

    # Client sentiment

    client_sentiment = build(:client_sentiment)

    expect(dealing_platform.client_sentiment).to receive(:[]).with('EURUSD').and_return(client_sentiment)
    expect(client_sentiment).to receive(:related_sentiments).and_return(build(:client_sentiment))

    # Accounts

    expect(dealing_platform.account).to receive(:all).and_return([build(:account)])
    expect(dealing_platform.account).to receive(:activities).and_return([build(:activity)])
    expect(dealing_platform.account).to receive(:transactions).and_return([build(:transaction)])

    # Applications

    expect(dealing_platform).to receive(:applications).and_return([build(:application)])

    # Streaming

    accounts_subscription = instance_double IGMarkets::Streaming::Subscription
    markets_subscription = instance_double IGMarkets::Streaming::Subscription
    trades_subscription = instance_double IGMarkets::Streaming::Subscription

    expect(accounts_subscription).to receive(:on_data) { |&block| 5.times { block.call '' } }
    expect(markets_subscription).to receive(:on_data) { |&block| 3.times { block.call '' } }
    expect(trades_subscription).to receive(:on_data) { |&block| 2.times { block.call '' } }

    expect(dealing_platform.streaming).to receive(:connect)
    expect(dealing_platform.streaming).to receive(:build_accounts_subscription).and_return(accounts_subscription)
    expect(dealing_platform.streaming).to receive(:build_markets_subscription).and_return(markets_subscription)
    expect(dealing_platform.streaming).to receive(:build_trades_subscription).and_return(trades_subscription)
    expect(dealing_platform.streaming).to receive(:start_subscriptions)
      .with([accounts_subscription, markets_subscription, trades_subscription], snapshot: true)
    expect(dealing_platform.streaming).to receive(:disconnect).twice

    cli.self_test
  end

  it 'raises an error when run on a live account' do
    expect(session).to receive(:platform).and_return(:live)
    expect { cli.self_test }.to raise_error('The self-test command must be run on a demo account')
  end
end

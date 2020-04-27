describe IGMarkets::CLI::Main, :cli_command do
  def cli(arguments = {})
    IGMarkets::CLI::Stream.new [], arguments
  end

  it 'streams the dashboard' do
    on_error_block = nil

    expect(dealing_platform.streaming).to receive(:connect)
    expect(dealing_platform.streaming).to receive(:on_error) { |&block| on_error_block = block }

    curses_window = instance_double 'IGMarkets::CLI::CursesWindow'
    expect(IGMarkets::CLI::CursesWindow).to receive(:new).and_return(curses_window)

    account_state = instance_double 'IGMarkets::Streaming::AccountState'
    expect(IGMarkets::Streaming::AccountState).to receive(:new).and_return(account_state)
    expect(account_state).to receive(:start)

    expect(account_state).to receive(:process_queued_data)
    expect(account_state).to receive(:accounts).and_return([])
    expect(account_state).to receive(:positions).and_return([])
    expect(account_state).to receive(:working_orders).and_return([])
    expect(curses_window).to receive(:clear)
    expect(curses_window).to receive(:print_lines)
    expect(curses_window).to receive(:refresh) { on_error_block.call 'error' }

    expect { cli.dashboard }.to raise_error('error')
  end

  it 'streams raw data' do
    cli_instance = cli accounts: true, trades: true, markets: ['ABC'], chart_ticks: ['DEF']

    accounts_subscription = instance_double 'IGMarkets::Streaming::Subscription', on_data: nil
    markets_subscription = instance_double 'IGMarkets::Streaming::Subscription', on_data: nil
    trades_subscription = instance_double 'IGMarkets::Streaming::Subscription', on_data: nil
    chart_ticks_subscription = instance_double 'IGMarkets::Streaming::Subscription', on_data: nil

    allow(dealing_platform).to receive(:client_account_summary).and_return(build(:client_account_summary))

    expect(dealing_platform.streaming).to receive(:connect)

    expect(dealing_platform.streaming).to receive(:build_accounts_subscription).and_return(accounts_subscription)
    expect(dealing_platform.streaming).to receive(:build_markets_subscription).and_return(markets_subscription)
    expect(dealing_platform.streaming).to receive(:build_trades_subscription).and_return(trades_subscription)
    expect(dealing_platform.streaming).to receive(:build_chart_ticks_subscription).and_return(chart_ticks_subscription)

    expect(dealing_platform.streaming).to receive(:start_subscriptions)
      .with([accounts_subscription, markets_subscription, trades_subscription, chart_ticks_subscription],
            snapshot: true) do
      cli_instance.send :on_data, build(:streaming_account_update), nil
      cli_instance.send :on_data, build(:streaming_market_update), nil
      cli_instance.send :on_data, build(:deal_confirmation), nil
      cli_instance.send :on_data, build(:streaming_position_update), nil
      cli_instance.send :on_data, build(:streaming_working_order_update), nil
      cli_instance.send :on_data, build(:streaming_chart_tick_update), nil
      cli_instance.send :on_error, Lightstreamer::Errors::SessionEndError.new(31)
    end

    expect { cli_instance.raw }.to output(<<~MSG
      AccountUpdate - account_id: ACCOUNT, available_cash: 8000.0, available_to_deal: 8000.0, deposit: 10000.0, equity: 10000.0, equity_used: 1000.0, funds: 10500.0, margin: 100.0, margin_lr: 100.0, margin_nlr: 0.0, pnl: 500.0, pnl_lr: 500.0, pnl_nlr: 0.0
      MarketUpdate - bid: 1.11, change: 0.02, change_pct: 1.2, epic: CS.D.EURUSD.CFD.IP, high: 1.2, low: 1.01, market_state: tradeable, mid_open: 1.11, offer: 1.12, strike_price: 1.11, update_time: 15:00:00
      DealConfirmation - deal_id: DEAL, deal_reference: reference, deal_status: accepted, direction: buy, epic: CS.D.EURUSD.CFD.IP, expiry: 2040-12-20, level: 100.0, limit_distance: 10, limit_level: 110.0, profit: 150.0, profit_currency: USD, reason: success, size: 19.5, status: amended, stop_distance: 10, stop_level: 90.0
      PositionUpdate - account_id: ACCOUNT, channel: web, currency: USD, deal_id: DEAL, deal_id_origin: DEAL2, deal_reference: reference, deal_status: accepted, direction: buy, epic: CS.D.EURUSD.CFD.IP, level: 1.1, limit_level: 1.2, size: 5.0, status: open, stop_level: 1.0, timestamp: 2015-12-15 15:00:00 +0000
      WorkingOrderUpdate - account_id: ACCOUNT, channel: Web, currency: USD, deal_id: DEAL, deal_reference: reference, deal_status: accepted, direction: buy, epic: CS.D.EURUSD.CFD.IP, good_till_date: 2015-12-17 14:00:00 +0000, level: 1.09, limit_distance: 50, order_type: stop, size: 5.0, status: open, stop_distance: 50, time_in_force: good_till_date, timestamp: 2015-12-15 15:00:00 +0000
      ChartTickUpdate - bid: 1.13, day_high: 1.15, day_low: 1.09, day_net_chg_mid: 0.02, day_open_mid: 1.11, day_perc_chg_mid: 1.2, epic: CS.D.EURUSD.CFD.IP, ltp: 1.13, ltv: 10.0, ofr: 1.132, ttv: 100.0, utm: 2016-08-09 08:24:16 +0000
    MSG
                                         ).to_stdout.and raise_error(Lightstreamer::Errors::SessionEndError)
  end
end

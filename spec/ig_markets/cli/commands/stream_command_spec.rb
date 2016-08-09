describe IGMarkets::CLI::Main, :cli_command do
  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: '', accounts: true, trades: true, markets: ['ABC']
  end

  it 'streams data' do
    accounts_subscription = instance_double 'Lightstreamer::Subscription'
    markets_subscription = instance_double 'Lightstreamer::Subscription'
    trades_subscription = instance_double 'Lightstreamer::Subscription'

    allow(dealing_platform).to receive(:client_account_summary).and_return(build(:client_account_summary))

    expect(dealing_platform.streaming).to receive(:connect)

    expect(dealing_platform.streaming).to receive(:build_accounts_subscription).and_return(accounts_subscription)
    expect(dealing_platform.streaming).to receive(:build_markets_subscription).and_return(markets_subscription)
    expect(dealing_platform.streaming).to receive(:build_trades_subscription).and_return(trades_subscription)

    expect(dealing_platform.streaming).to receive(:start_subscriptions)
      .with([accounts_subscription, markets_subscription, trades_subscription], snapshot: true)

    expect(dealing_platform.streaming).to receive(:pop_data).and_return(data: build(:streaming_account_update))
    expect(dealing_platform.streaming).to receive(:pop_data).and_return(data: build(:streaming_market_update))
    expect(dealing_platform.streaming).to receive(:pop_data).and_return(data: build(:deal_confirmation))
    expect(dealing_platform.streaming).to receive(:pop_data).and_return(data: build(:streaming_position_update))
    expect(dealing_platform.streaming).to receive(:pop_data).and_return(data: build(:streaming_working_order_update))
    expect(dealing_platform.streaming).to receive(:pop_data).and_return(Lightstreamer::Errors::SessionEndError.new(31))

    expect { cli.stream }.to output(<<-END
AccountUpdate - account_id: ABC1234, available_cash: 8000.0, available_to_deal: 8000.0, deposit: 10000.0, equity: 10000.0, equity_used: 1000.0, funds: 10500.0, margin: 100.0, margin_lr: 100.0, margin_nlr: 0.0, pnl: 500.0, pnl_lr: 500.0, pnl_nlr: 0.0
MarketUpdate - bid: 1.11, change: 0.02, change_pct: 1.2, epic: CS.D.EURUSD.CFD.IP, high: 1.2, low: 1.01, market_state: tradeable, mid_open: 1.11, offer: 1.12, strike_price: 1.11
DealConfirmation - deal_id: DEAL, deal_reference: REFERENCE, deal_status: accepted, direction: buy, epic: CS.D.EURUSD.CFD.IP, expiry: 2040-12-20, level: 100.0, limit_distance: 10, limit_level: 110.0, profit: 150.0, profit_currency: USD, reason: success, size: 19.5, status: amended, stop_distance: 10, stop_level: 90.0
PositionUpdate - account_id: ABC1234, channel: web, deal_id: id, deal_id_origin: id, deal_reference: ref, deal_status: accepted, direction: buy, epic: CS.D.EURUSD.CFD.IP, level: 1.1, limit_level: 1.2, size: 5.0, status: open, stop_level: 1.0
WorkingOrderUpdate - account_id: ABC1234, channel: web, deal_id: id, deal_reference: ref, deal_status: accepted, direction: buy, epic: CS.D.EURUSD.CFD.IP, level: 1.09, limit_distance: 50, size: 5.0, status: open, stop_distance: 50
END
                                   ).to_stdout.and raise_error(Lightstreamer::Errors::SessionEndError)
  end
end

describe IGMarkets::CLI::Main, :cli_command do
  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: '', accounts: true, trades: true, markets: ['ABC']
  end

  it 'streams data' do
    on_error_block = nil
    account_on_data = nil
    market_on_data = nil
    trade_on_data = nil

    lightstreamer_session = instance_double 'Lightstreamer::Session'
    account_subscription = instance_double 'Lightstreamer::Subscription'
    market_subscription = instance_double 'Lightstreamer::Subscription'
    trade_subscription = instance_double 'Lightstreamer::Subscription'

    expect(dealing_platform).to receive(:lightstreamer_session).and_return(lightstreamer_session)
    allow(dealing_platform).to receive(:client_account_summary).and_return(build(:client_account_summary))

    expect(lightstreamer_session).to receive(:on_error) { |&block| on_error_block = block }

    expect(lightstreamer_session).to receive(:build_subscription)
      .with(items: ['ACCOUNT:123456'],
            fields: [:pnl, :deposit, :available_cash, :funds, :margin, :available_to_deal, :equity], mode: :merge)
      .and_return(account_subscription)

    expect(lightstreamer_session).to receive(:build_subscription)
      .with(items: %w(MARKET:ABC), fields: [:bid, :offer, :high, :low, :mid_open, :strike_price, :odds], mode: :merge)
      .and_return(market_subscription)

    expect(lightstreamer_session).to receive(:build_subscription)
      .with(items: ['TRADE:123456'], fields: [:confirms, :opu, :wou], mode: :distinct)
      .and_return(trade_subscription)

    expect(account_subscription).to receive(:on_data) { |&block| account_on_data = block }
    expect(market_subscription).to receive(:on_data) { |&block| market_on_data = block }
    expect(trade_subscription).to receive(:on_data) { |&block| trade_on_data = block }

    expect(lightstreamer_session).to receive(:connect)

    account_data = { pnl: 500.0, deposit: 10_000.0, available_cash: 8_000.0, funds: 10_500.0, margin: 100.0,
                     available_to_deal: 800.0, equity: 10_000.0 }

    market_data = { bid: 1.11, offer: 1.12, high: 1.2, low: 1.01, mid_open: 1.11, strike_price: 1.11 }

    trade_data = { confirms: { deal_id: 'id', status: 'OPEN', epic: 'CS.D.EURUSD.CFD.IP', direction: 'BUY', size: 1,
                               level: 1.1, profit: 100.0, profit_currency: 'USD' }.to_json,
                   opu: { deal_id: 'id', deal_status: 'REJECTED', direction: 'BUY', epic: 'CS.D.EURUSD.CFD.IP',
                          level: 1.1, limit_level: 1.2, size: 5, status: 'OPEN', stop_level: 1.0 }.to_json,
                   wou: { deal_id: 'id', deal_status: 'ACCEPTED', direction: 'BUY', epic: 'CS.D.EURUSD.CFD.IP',
                          level: 1.09, limit_distance: 50, size: 5, status: 'OPEN', stop_distance: 50 }.to_json }

    expect(lightstreamer_session).to receive(:bulk_subscription_start)
      .with([account_subscription, market_subscription, trade_subscription], snapshot: true) do
      account_on_data.call account_subscription, 'ACCOUNT:123456', account_data, account_data
      market_on_data.call market_subscription, 'MARKET:ABC', market_data, market_data
      trade_on_data.call trade_subscription, 'TRADE:123456', trade_data, trade_data
      on_error_block.call Lightstreamer::Errors::SessionEndError.new(31)
    end

    expect { cli.stream }.to output(<<-END
ACCOUNT:123456 - pnl: 500.0, deposit: 10000.0, available_cash: 8000.0, funds: 10500.0, margin: 100.0, available_to_deal: 800.0, equity: 10000.0
MARKET:ABC - bid: 1.11, offer: 1.12, high: 1.2, low: 1.01, mid_open: 1.11, strike_price: 1.11
TRADE:123456 - Confirmation - id: id, status: open, epic: CS.D.EURUSD.CFD.IP, direction: buy, size: 1.0, level: 1.1, profit: USD 100.00
TRADE:123456 - Position update - id: id, status: open, deal_status: rejected, epic: CS.D.EURUSD.CFD.IP, direction: buy, size: 5.0, level: 1.1, stop_level: 1.0, limit_level: 1.2
TRADE:123456 - Order update - id: id, status: open, deal_status: accepted, epic: CS.D.EURUSD.CFD.IP, direction: buy, size: 5.0, level: 1.09, stop_distance: 50, limit_distance: 50
END
                                   ).to_stdout.and raise_error(Lightstreamer::Errors::SessionEndError)
  end
end

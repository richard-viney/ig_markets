describe IGMarkets::Streaming::Subscription, :dealing_platform do
  let(:lightstreamer_subscription) { instance_double 'Lightstreamer::Subscription', on_data: nil }
  let(:subscription) { IGMarkets::Streaming::Subscription.new dealing_platform, lightstreamer_subscription }

  it 'unsilences itself' do
    expect(lightstreamer_subscription).to receive(:unsilence)

    subscription.unsilence
  end

  it 'runs data callbacks' do
    on_data_invocations = []
    subscription.on_data { |*arguments| on_data_invocations << arguments }
    subscription.send :run_callbacks, 1, 2
    expect(on_data_invocations).to eq([[1, 2]])
  end

  it 'processes account data' do
    item_data = { pnl: '500', deposit: '10000', available_cash: '8000', funds: '10500', margin: '100',
                  available_to_deal: '800', equity: '10000' }
    model = IGMarkets::Streaming::AccountUpdate.new item_data.merge(account_id: 'ACCOUNT')

    expect(subscription).to receive(:run_callbacks).with(model, model)

    subscription.send :on_raw_data, nil, 'ACCOUNT:ACCOUNT', item_data, item_data
  end

  it 'processes market data' do
    item_data = { bid: '1.11', offer: '1.12', high: '1.2', low: '1.01', mid_open: '1.11', strike_price: '1.11' }
    model = IGMarkets::Streaming::MarketUpdate.new item_data.merge(epic: 'CS.D.EURUSD.CFD.IP')

    expect(subscription).to receive(:run_callbacks).with(model, model)

    subscription.send :on_raw_data, nil, 'MARKET:CS.D.EURUSD.CFD.IP', item_data, item_data
  end

  it 'processes a deal confirmation' do
    item_data = { deal_id: 'id', status: 'OPEN', epic: 'CS.D.EURUSD.CFD.IP', direction: 'BUY', size: '1',
                  level: '1.1', profit: '100', profit_currency: 'USD' }
    model = IGMarkets::DealConfirmation.new item_data.merge(account_id: 'ACCOUNT')

    expect(subscription).to receive(:run_callbacks).with(model)

    subscription.send :on_raw_data, nil, 'TRADE:ACCOUNT', nil, confirms: item_data.to_json
  end

  it 'processes a position update' do
    item_data = { deal_id: 'id', deal_status: 'REJECTED', direction: 'BUY', epic: 'CS.D.EURUSD.CFD.IP', level: '1.1',
                  limit_level: '1.2', size: '5', status: 'OPEN', stop_level: '1' }
    model = IGMarkets::Streaming::PositionUpdate.new item_data.merge(account_id: 'ACCOUNT')

    expect(subscription).to receive(:run_callbacks).with(model)

    subscription.send :on_raw_data, nil, 'TRADE:ACCOUNT', nil, opu: item_data.to_json
  end

  it 'processes a working order update' do
    item_data = { deal_id: 'id', deal_status: 'ACCEPTED', direction: 'BUY', epic: 'CS.D.EURUSD.CFD.IP', level: '1.09',
                  limit_distance: '50', size: '5', status: 'OPEN', stop_distance: '50' }
    model = IGMarkets::Streaming::WorkingOrderUpdate.new item_data.merge(account_id: 'ACCOUNT')

    expect(subscription).to receive(:run_callbacks).with(model)

    subscription.send :on_raw_data, nil, 'TRADE:ACCOUNT', nil, wou: item_data.to_json
  end

  it 'processes a chart tick update' do
    item_data = { bid: '1.13', day_high: '1.15', day_low: '1.09', day_net_chg_mid: '0.02', day_open_mid: '1.11',
                  day_perc_chg_mid: '1.2', epic: 'CS.D.EURUSD.CFD.IP', ltp: '1.13', ltv: '10', ofr: '1.132',
                  ttv: '100', utm: '1470731056283' }
    model = IGMarkets::Streaming::ChartTickUpdate.new item_data.merge(epic: 'CS.D.EURUSD.CFD.IP')

    expect(subscription).to receive(:run_callbacks).with(model)

    subscription.send :on_raw_data, nil, 'CHART:CS.D.EURUSD.CFD.IP:TICK', nil, item_data
  end

  it 'processes a consolidated chart data update' do
    item_data = { bid_close: '1.10883', bid_high: '1.10886', bid_low: '1.10877', bid_open: '1.10878',
                  cons_tick_count: '58', day_high: '1.10967', day_low: '1.10703', day_net_chg_mid: '0.00006',
                  day_open_mid: '1.1088', day_perc_chg_mid: '0.01', ltv: '58', ofr_close: '1.10889',
                  ofr_high: '1.10892', ofr_low: '1.10883', ofr_open: '1.10884', utm: '1470731056283' }
    model = IGMarkets::Streaming::ConsolidatedChartDataUpdate.new item_data.merge(epic: 'CS.D.EURUSD.CFD.IP',
                                                                                  scale: :one_hour)

    expect(subscription).to receive(:run_callbacks).with(model, model)

    subscription.send :on_raw_data, nil, 'CHART:CS.D.EURUSD.CFD.IP:HOUR', item_data, item_data
  end
end

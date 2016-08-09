describe IGMarkets::DealingPlatform::StreamingMethods, :dealing_platform do
  let(:lightstreamer_session) { instance_double 'Lightstreamer::Session' }

  before do
    dealing_platform.instance_variable_set :@client_account_summary, build(:client_account_summary)
  end

  it 'connects a Lightstreamer session' do
    expect(dealing_platform.session).to receive(:client_security_token).and_return('cst')
    expect(dealing_platform.session).to receive(:x_security_token).and_return('xst')

    lightstreamer_session = instance_double 'Lightstreamer::Session'

    expect(Lightstreamer::Session).to receive(:new)
      .with(server_url: 'http://lightstreamer.com', username: 'ABC123', password: 'CST-cst|XST-xst')
      .and_return(lightstreamer_session)

    expect(lightstreamer_session).to receive(:on_error)
    expect(lightstreamer_session).to receive(:connect)

    dealing_platform.streaming.connect
  end

  context 'with an active session' do
    let(:queue) { instance_double 'Queue' }

    before do
      dealing_platform.streaming.instance_variable_set :@lightstreamer, lightstreamer_session
      dealing_platform.streaming.instance_variable_set :@queue, queue
    end

    it 'disconnects' do
      expect(lightstreamer_session).to receive(:disconnect)

      dealing_platform.streaming.disconnect
    end

    it 'builds an accounts subscription' do
      subscription = instance_double 'Lightstreamer::Subscription'

      expect(lightstreamer_session).to receive(:build_subscription)
        .with(items: ['ACCOUNT:123456'],
              fields: [:pnl, :deposit, :available_cash, :funds, :margin, :available_to_deal, :equity], mode: :merge)
        .and_return(subscription)
      expect(subscription).to receive(:on_data) { |&block| expect(block).to be_a(Proc) }

      expect(dealing_platform.streaming.build_accounts_subscription).to eq(subscription)
    end

    it 'builds a markets subscription' do
      subscription = instance_double 'Lightstreamer::Subscription'

      expect(lightstreamer_session).to receive(:build_subscription)
        .with(items: ['MARKET:ABC1234', 'MARKET:DEF5678'],
              fields: [:bid, :offer, :high, :low, :mid_open, :strike_price, :odds], mode: :merge)
        .and_return(subscription)
      expect(subscription).to receive(:on_data) { |&block| expect(block).to be_a(Proc) }

      expect(dealing_platform.streaming.build_markets_subscription(%w(ABC1234 DEF5678))).to eq(subscription)
    end

    it 'builds a trades subscription' do
      subscription = instance_double 'Lightstreamer::Subscription'

      expect(lightstreamer_session).to receive(:build_subscription)
        .with(items: ['TRADE:123456'], fields: [:confirms, :opu, :wou], mode: :distinct)
        .and_return(subscription)
      expect(subscription).to receive(:on_data) { |&block| expect(block).to be_a(Proc) }

      expect(dealing_platform.streaming.build_trades_subscription).to eq(subscription)
    end

    it 'starts subscriptions' do
      expect(lightstreamer_session).to receive(:bulk_subscription_start).with([1, 2], snapshot: true)

      dealing_platform.streaming.start_subscriptions [1, 2], snapshot: true
    end

    it 'stops a subscription' do
      expect(lightstreamer_session).to receive(:remove_subscription).with(:subscription)

      dealing_platform.streaming.stop_subscription :subscription
    end

    it 'pops available data' do
      expect(lightstreamer_session).to receive(:connected?).and_return(true)
      expect(queue).to receive(:pop).and_return(build(:streaming_position_update))
      expect(dealing_platform.streaming.pop_data).to eq(build(:streaming_position_update))

      expect(lightstreamer_session).to receive(:connected?).and_return(false)
      expect(dealing_platform.streaming.pop_data).to eq(nil)
    end

    it 'checks whether data is available' do
      expect(queue).to receive(:empty?).and_return(true)
      expect(dealing_platform.streaming.data_available?).to be false

      expect(queue).to receive(:empty?).and_return(false)
      expect(dealing_platform.streaming.data_available?).to be true
    end

    it 'processes an error' do
      expect(queue).to receive(:push).with(instance_of(Lightstreamer::LightstreamerError))

      dealing_platform.streaming.send :on_error, Lightstreamer::LightstreamerError.new
    end

    it 'processes account data' do
      item_data = { pnl: '500', deposit: '10000', available_cash: '8000', funds: '10500', margin: '100',
                    available_to_deal: '800', equity: '10000' }
      model = IGMarkets::Streaming::AccountUpdate.new item_data.merge(account_id: 'ABC1234')

      expect(queue).to receive(:push).with(data: model, merged_data: model)

      dealing_platform.streaming.send :on_account_data, nil, 'ACCOUNT:ABC1234', item_data, item_data
    end

    it 'processes market data' do
      item_data = { bid: '1.11', offer: '1.12', high: '1.2', low: '1.01', mid_open: '1.11', strike_price: '1.11' }
      model = IGMarkets::Streaming::MarketUpdate.new item_data.merge(epic: 'ABC1234')

      expect(queue).to receive(:push).with(data: model, merged_data: model)

      dealing_platform.streaming.send :on_market_data, nil, 'MARKET:ABC1234', item_data, item_data
    end

    it 'processes a deal confirmation' do
      item_data = { deal_id: 'id', status: 'OPEN', epic: 'CS.D.EURUSD.CFD.IP', direction: 'BUY', size: '1',
                    level: '1.1', profit: '100', profit_currency: 'USD' }
      model = IGMarkets::DealConfirmation.new item_data.merge(account_id: 'ABC1234')

      expect(queue).to receive(:push).with(data: model)

      dealing_platform.streaming.send :on_trade_data, nil, 'TRADE:ABC1234', nil, confirms: item_data.to_json
    end

    it 'processes a position update' do
      item_data = { deal_id: 'id', deal_status: 'REJECTED', direction: 'BUY', epic: 'CS.D.EURUSD.CFD.IP', level: '1.1',
                    limit_level: '1.2', size: '5', status: 'OPEN', stop_level: '1' }
      model = IGMarkets::Streaming::PositionUpdate.new item_data.merge(account_id: 'ABC1234')

      expect(queue).to receive(:push).with(data: model)

      dealing_platform.streaming.send :on_trade_data, nil, 'TRADE:ABC1234', nil, opu: item_data.to_json
    end

    it 'processes a working order update' do
      item_data = { deal_id: 'id', deal_status: 'ACCEPTED', direction: 'BUY', epic: 'CS.D.EURUSD.CFD.IP', level: '1.09',
                    limit_distance: '50', size: '5', status: 'OPEN', stop_distance: '50' }
      model = IGMarkets::Streaming::WorkingOrderUpdate.new item_data.merge(account_id: 'ABC1234')

      expect(queue).to receive(:push).with(data: model)

      dealing_platform.streaming.send :on_trade_data, nil, 'TRADE:ABC1234', nil, wou: item_data.to_json
    end
  end
end

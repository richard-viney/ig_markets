describe IGMarkets::Streaming::AccountState, :dealing_platform do
  let(:data_queue) { Queue.new }
  let(:market_subscriptions_manager) { instance_double 'IGMarkets::Streaming::MarketSubscriptionManager', on_data: nil }

  let(:accounts_subscription) { instance_double 'IGMarkets::Streaming::Subscription' }
  let(:trades_subscription) { instance_double 'IGMarkets::Streaming::Subscription' }

  let(:account_state) do
    IGMarkets::Streaming::AccountState.new(dealing_platform).tap do |account_state|
      account_state.instance_variable_set :@data_queue, data_queue
    end
  end

  it 'checks whether there is data to process' do
    expect(account_state.data_queue_empty?).to be true
    data_queue.push :test
    expect(account_state.data_queue_empty?).to be false
  end

  it 'streams and processes live data' do
    accounts_on_data_callback = nil
    trades_on_data_callback = nil

    expect(IGMarkets::Streaming::MarketSubscriptionManager).to receive(:new).and_return(market_subscriptions_manager)

    expect(accounts_subscription).to receive(:on_data) { |&callback| accounts_on_data_callback = callback }
    expect(trades_subscription).to receive(:on_data) { |&callback| trades_on_data_callback = callback }

    expect(dealing_platform.streaming).to receive(:build_accounts_subscription).and_return(accounts_subscription)
    expect(dealing_platform.streaming).to receive(:build_trades_subscription).and_return(trades_subscription)
    expect(dealing_platform.streaming).to receive(:start_subscriptions).with(accounts_subscription, snapshot: true)
    expect(dealing_platform.streaming).to receive(:start_subscriptions).with(trades_subscription, silent: true)

    expect(dealing_platform.account).to receive(:all).and_return([build(:account)])
    expect(dealing_platform.positions).to receive(:all).and_return([build(:position, deal_id: '1')])
    expect(dealing_platform.working_orders).to receive(:all).and_return([build(:working_order, deal_id: '1')])

    expect(trades_subscription).to receive(:unsilence)

    expect(market_subscriptions_manager).to receive(:epics=).twice.with(['CS.D.EURUSD.CFD.IP', 'CS.D.EURUSD.CFD.IP'])

    account_state.start

    expect(dealing_platform.positions).to receive(:[]).with('2').and_return(build(:position, deal_id: '2'))
    expect(dealing_platform.working_orders).to receive(:[]).with('2').and_return(build(:working_order, deal_id: '2'))

    data_queue.push [:on_market_update, build(:streaming_market_update)]

    accounts_on_data_callback.call nil, build(:streaming_account_update)
    trades_on_data_callback.call build(:streaming_position_update, status: :open, deal_id: '2')
    trades_on_data_callback.call build(:streaming_position_update, status: :updated, deal_id: '1')
    trades_on_data_callback.call build(:streaming_position_update, status: :deleted, deal_id: '1')
    trades_on_data_callback.call build(:streaming_position_update, status: :updated, deal_id: '2', stop_level: 1.23)
    trades_on_data_callback.call build(:streaming_working_order_update, status: :open, deal_id: '2')
    trades_on_data_callback.call build(:streaming_working_order_update, status: :updated, deal_id: '1')
    trades_on_data_callback.call build(:streaming_working_order_update, status: :deleted, deal_id: '1')
    trades_on_data_callback.call build(:streaming_working_order_update, status: :updated, deal_id: '2', level: 123)

    account_state.process_queued_data

    expect(account_state.positions.map(&:deal_id)).to eq(['2'])
    expect(account_state.positions.first.stop_level).to be(1.23)

    expect(account_state.working_orders.map(&:deal_id)).to eq(['2'])
    expect(account_state.working_orders.first.order_level).to eq(123)
  end
end

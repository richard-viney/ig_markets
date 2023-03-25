describe IGMarkets::Streaming::MarketSubscriptionManager, :dealing_platform do
  let(:market_subscriptions) { described_class.new dealing_platform }

  it 'clears subscriptions' do
    expect(dealing_platform.streaming).to receive(:remove_subscriptions)

    market_subscriptions.clear
  end

  it 'adjusts subscriptions when EPICs change' do
    subscription = instance_double IGMarkets::Streaming::Subscription, on_data: nil

    expect(dealing_platform.streaming).to receive(:build_markets_subscription).with('1').and_return(subscription)
    expect(dealing_platform.streaming).to receive(:build_markets_subscription).with('2').and_return(subscription)
    expect(dealing_platform.streaming).to receive(:start_subscriptions)
      .with([subscription, subscription], snapshot: true)
    expect(dealing_platform.streaming).to receive(:remove_subscriptions).with([])

    market_subscriptions.epics = %w[1 2]

    expect(dealing_platform.streaming).to receive(:start_subscriptions).with([], snapshot: true)
    expect(dealing_platform.streaming).to receive(:remove_subscriptions).with([subscription])

    market_subscriptions.epics = ['1']

    expect(dealing_platform.streaming).to receive(:build_markets_subscription).with('3').and_return(subscription)
    expect(dealing_platform.streaming).to receive(:start_subscriptions).with([subscription], snapshot: true)
    expect(dealing_platform.streaming).to receive(:remove_subscriptions).with([subscription])

    market_subscriptions.epics = ['3']
  end

  it 'runs callbacks when data is received' do
    received_data = nil

    market_subscriptions.on_data { |*arguments| received_data = arguments }
    market_subscriptions.send :run_callbacks, 1, 2

    expect(received_data).to eq([1, 2])
  end
end

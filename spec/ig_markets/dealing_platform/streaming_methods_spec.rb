describe IGMarkets::DealingPlatform::StreamingMethods, :dealing_platform do
  let(:lightstreamer_session) { instance_double Lightstreamer::Session }

  before do
    dealing_platform.instance_variable_set :@client_account_summary, build(:client_account_summary)
  end

  it 'connects a Lightstreamer session' do
    expect(dealing_platform.session).to receive(:client_security_token).and_return('cst')
    expect(dealing_platform.session).to receive(:x_security_token).and_return('xst')

    lightstreamer_session = instance_double Lightstreamer::Session

    expect(Lightstreamer::Session).to receive(:new)
      .with(server_url: 'http://lightstreamer.com', username: 'CLIENT', password: 'CST-cst|XST-xst')
      .and_return(lightstreamer_session)

    on_error_block = nil

    expect(lightstreamer_session).to receive(:on_error) { |&block| on_error_block = block }
    expect(lightstreamer_session).to receive(:connect)

    dealing_platform.streaming.connect

    on_error_callback_ran = false
    dealing_platform.streaming.on_error { on_error_callback_ran = true }
    on_error_block.call nil
    expect(on_error_callback_ran).to be true
  end

  context 'with an active session' do
    let(:queue) { instance_double Queue }

    before do
      dealing_platform.streaming.instance_variable_set :@lightstreamer, lightstreamer_session
      dealing_platform.streaming.instance_variable_set :@queue, queue
    end

    it 'disconnects' do
      expect(lightstreamer_session).to receive(:disconnect)

      dealing_platform.streaming.disconnect
    end

    it 'builds an accounts subscription' do
      subscription = instance_double Lightstreamer::Subscription

      expect(subscription).to receive(:on_data)

      expect(lightstreamer_session).to receive(:build_subscription)
        .with({
                items: ['ACCOUNT:ACCOUNT'],
                fields: %i[available_cash available_to_deal deposit equity equity_used funds margin margin_lr margin_nlr
                           pnl pnl_lr pnl_nlr],
                mode: :merge
              })
        .and_return(subscription)

      expect(dealing_platform.streaming.build_accounts_subscription).to be_a(IGMarkets::Streaming::Subscription)
    end

    it 'builds a markets subscription' do
      subscription = instance_double Lightstreamer::Subscription

      expect(subscription).to receive(:on_data)

      expect(lightstreamer_session).to receive(:build_subscription)
        .with({
                items: ['MARKET:ABC1234', 'MARKET:DEF5678'],
                fields: %i[bid change change_pct high low market_delay market_state mid_open odds offer strike_price
                           update_time],
                mode: :merge
              })
        .and_return(subscription)

      expect(dealing_platform.streaming.build_markets_subscription(%w[ABC1234 DEF5678]))
        .to be_a(IGMarkets::Streaming::Subscription)
    end

    it 'builds a trades subscription' do
      subscription = instance_double Lightstreamer::Subscription

      expect(subscription).to receive(:on_data)

      expect(lightstreamer_session).to receive(:build_subscription)
        .with({ items: ['TRADE:ACCOUNT'], fields: %i[confirms opu wou], mode: :distinct })
        .and_return(subscription)

      expect(dealing_platform.streaming.build_trades_subscription).to be_a(IGMarkets::Streaming::Subscription)
    end

    it 'builds a chart ticks subscription' do
      subscription = instance_double Lightstreamer::Subscription

      expect(subscription).to receive(:on_data)

      expect(lightstreamer_session).to receive(:build_subscription)
        .with({
                items: ['CHART:ABC1234:TICK', 'CHART:DEF5678:TICK'],
                mode: :distinct,
                fields: %i[bid day_high day_low day_net_chg_mid day_open_mid day_perc_chg_mid ltp ltv ofr ttv utm]
              })
        .and_return(subscription)

      expect(dealing_platform.streaming.build_chart_ticks_subscription(%w[ABC1234 DEF5678]))
        .to be_a(IGMarkets::Streaming::Subscription)
    end

    it 'builds a consolidated chart data subscription' do
      subscription = instance_double Lightstreamer::Subscription

      expect(subscription).to receive(:on_data)

      expect(lightstreamer_session).to receive(:build_subscription)
        .with({
                items: ['CHART:ABC1234:1MINUTE'],
                mode: :merge,
                fields: %i[bid_close bid_high bid_low bid_open cons_end cons_tick_count day_high day_low day_net_chg_mid
                           day_open_mid day_perc_chg_mid ltp_close ltp_high ltp_low ltp_open ltv ofr_close ofr_high
                           ofr_low ofr_open ttv utm]
              })
        .and_return(subscription)

      expect(dealing_platform.streaming.build_consolidated_chart_data_subscription('ABC1234', :one_minute))
        .to be_a(IGMarkets::Streaming::Subscription)
    end

    it 'starts subscriptions' do
      lightstreamer_subscription = instance_double Lightstreamer::Subscription
      streaming_subscription = instance_double IGMarkets::Streaming::Subscription,
                                               lightstreamer_subscription: lightstreamer_subscription

      expect(lightstreamer_session).to receive(:start_subscriptions).with([lightstreamer_subscription], {})

      dealing_platform.streaming.start_subscriptions streaming_subscription
      dealing_platform.streaming.start_subscriptions [nil]
    end

    it 'removes subscriptions' do
      lightstreamer_subscription = instance_double Lightstreamer::Subscription
      streaming_subscription = instance_double IGMarkets::Streaming::Subscription,
                                               lightstreamer_subscription: lightstreamer_subscription

      expect(lightstreamer_session).to receive(:remove_subscriptions).with([lightstreamer_subscription])

      dealing_platform.streaming.remove_subscriptions streaming_subscription
      dealing_platform.streaming.remove_subscriptions [nil]
    end
  end
end

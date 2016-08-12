FactoryGirl.define do
  factory :streaming_market_update, class: IGMarkets::Streaming::MarketUpdate do
    bid 1.11
    change 0.02
    change_pct 1.2
    epic 'CS.D.EURUSD.CFD.IP'
    high 1.2
    low 1.01
    market_delay false
    market_state'TRADEABLE'
    mid_open 1.11
    odds nil
    offer 1.12
    strike_price 1.11
    update_time '15:00:00'
  end
end

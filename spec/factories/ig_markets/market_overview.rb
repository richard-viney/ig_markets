FactoryGirl.define do
  factory :market_overview, class: IGMarkets::MarketOverview do
    bid 100
    delay_time 0.0
    epic 'CS.D.EURUSD.CFD.IP'
    exchange_id nil
    expiry '-'
    high 110.0
    instrument_name 'Spot FX EUR/USD'
    instrument_type 'CURRENCIES'
    lot_size 10.0
    low 90.0
    market_status 'TRADEABLE'
    net_change 5
    offer 99
    percentage_change 5
    scaling_factor 10.0
    streaming_prices_available true
    update_time '01:09:48'
    update_time_utc '04:09:48'
  end
end

FactoryGirl.define do
  factory :market, class: IGMarkets::Market do
    bid 100
    delay_time '1'
    epic 'epic'
    exchange_id 'exchange_id'
    expiry ''
    high 110.0
    instrument_name 'instrument'
    instrument_type 'SHARES'
    lot_size 1000.0
    low 90.0
    market_status 'TRADEABLE'
    net_change 5
    offer 99
    percentage_change 5
    scaling_factor 10.0
    streaming_prices_available true
    update_time '12:00'
  end
end

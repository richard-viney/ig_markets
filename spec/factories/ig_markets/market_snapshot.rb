FactoryGirl.define do
  factory :market_snapshot, class: IGMarkets::MarketSnapshot do
    bid 100.0
    binary_odds 0.5
    controlled_risk_extra_spread 0.01
    decimal_places_factor 1
    delay_time 1
    high 110.0
    low 90.0
    market_status 'TRADEABLE'
    net_change 10.0
    offer 99.0
    percentage_change 10
    scaling_factor 100
    update_time '22:10:40'
  end
end

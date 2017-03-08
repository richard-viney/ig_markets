FactoryGirl.define do
  factory :position, class: IGMarkets::Position do
    contract_size 1000.0
    controlled_risk false
    created_date '2015/08/17 10:27:28:000'
    created_date_utc '2015-07-24T09:12:37'
    currency 'USD'
    deal_id 'DEAL'
    deal_reference 'reference'
    direction 'BUY'
    level 100.0
    limit_level 110.0
    limited_risk_premium { build :limited_risk_premium }
    size 10.4
    stop_level 90.0
    trailing_step nil
    trailing_stop_distance nil

    market { build :market_overview }
  end
end

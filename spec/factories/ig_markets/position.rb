FactoryGirl.define do
  factory :position, class: IGMarkets::Position do
    contract_size 1000.0
    controlled_risk false
    created_date '2015/08/17 10:27:28:000'
    created_date_utc '2015-07-24T09:12:37'
    currency 'USD'
    deal_id 'DIAAAAA8JKPFTVA'
    direction 'BUY'
    level 100.0
    limit_level 110.0
    size 1
    stop_level 90.0
    trailing_step nil
    trailing_stop_distance nil

    market { build(:market) }
  end
end

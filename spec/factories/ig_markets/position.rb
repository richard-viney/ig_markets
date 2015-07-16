FactoryGirl.define do
  factory :position, class: IGMarkets::Position do
    contract_size 1000.0
    controlled_risk false
    created_date '22-01-2015'
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

FactoryGirl.define do
  factory :position, class: IGMarkets::Position do
    contract_size 1
    controlled_risk true
    created_date '22-01-2015'
    currency 'USD'
    deal_id 'id'
    direction 'BUY'
    level 100.0
    limit_level 110.0
    size 1
    stop_level 90.0
    trailing_step 0.1
    trailing_stop_distance 1

    market { build(:market) }
  end
end

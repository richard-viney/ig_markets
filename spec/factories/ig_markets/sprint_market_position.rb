FactoryGirl.define do
  factory :sprint_market_position, class: IGMarkets::SprintMarketPosition do
    created_date '2014-10-22'
    currency 'USD'
    deal_id 'deal_id'
    description 'description'
    direction 'BUY'
    epic 'epic'
    expiry_time 'epic'
    instrument_name 'instrument'
    market_status 'TRADEABLE'
    payout_amount 100.0
    size 1.0
    strike_level 110.0
  end
end

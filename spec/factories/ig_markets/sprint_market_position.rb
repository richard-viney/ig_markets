FactoryGirl.define do
  factory :sprint_market_position, class: IGMarkets::SprintMarketPosition do
    created_date '2014/10/22 18:30:15:000'
    currency 'USD'
    deal_id 'deal_id'
    description 'description'
    direction 'BUY'
    epic 'UA.D.AAPL.CASH.IP'
    expiry_time '2014/10/22 19:30:14:000'
    instrument_name 'instrument'
    market_status 'TRADEABLE'
    payout_amount 100.0
    size 1
    strike_level 110.0
  end
end

FactoryGirl.define do
  factory :sprint_market_position, class: IGMarkets::SprintMarketPosition do
    created_date '2014/10/22 18:30:15:000'
    currency 'USD'
    deal_id 'DEAL'
    description 'Description'
    direction 'BUY'
    epic 'FM.D.FTSE.FTSE.IP'
    expiry_time '2014/10/22 19:30:14:000'
    instrument_name 'Instrument'
    market_status 'TRADEABLE'
    payout_amount 210.8
    size 120.50
    strike_level 110.1
  end
end

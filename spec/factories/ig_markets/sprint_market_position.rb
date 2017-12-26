FactoryBot.define do
  factory :sprint_market_position, class: IGMarkets::SprintMarketPosition do
    created_date '2014-10-22T18:30:15'
    currency 'USD'
    deal_id 'DEAL'
    description 'Description'
    direction 'BUY'
    epic 'FM.D.FTSE.FTSE.IP'
    expiry_time '2014-10-22T19:30:14'
    instrument_name 'Instrument'
    market_status 'TRADEABLE'
    payout_amount 210.8
    size 120.50
    strike_level 110.1
  end
end

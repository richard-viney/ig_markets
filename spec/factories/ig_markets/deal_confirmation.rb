FactoryGirl.define do
  factory :deal_confirmation, class: IGMarkets::DealConfirmation do
    affected_deals []
    deal_id 'DEAL'
    deal_reference 'REFERENCE'
    deal_status 'ACCEPTED'
    direction 'BUY'
    epic 'CS.D.EURUSD.CFD.IP'
    expiry '20-DEC-40'
    guaranteed_stop false
    level 100.0
    limit_distance 10
    limit_level 110.0
    profit 150.0
    profit_currency 'USD'
    reason 'SUCCESS'
    size 19.5
    status 'AMENDED'
    stop_distance 10
    stop_level 90.0
    trailing_stop false
  end
end

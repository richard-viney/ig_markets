FactoryGirl.define do
  factory :streaming_working_order_update, class: IGMarkets::Streaming::WorkingOrderUpdate do
    account_id 'ABC1234'
    channel 'web'
    deal_id 'id'
    deal_reference 'ref'
    deal_status 'ACCEPTED'
    direction 'BUY'
    epic 'CS.D.EURUSD.CFD.IP'
    expiry '-'
    guaranteed_stop false
    level 1.09
    limit_distance 50
    size 5
    status 'OPEN'
    stop_distance 50
    timestamp '2015-12-15T15:00:00.123'
  end
end

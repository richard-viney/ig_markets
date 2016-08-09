FactoryGirl.define do
  factory :streaming_position_update, class: IGMarkets::Streaming::PositionUpdate do
    account_id 'ABC1234'
    channel 'web'
    deal_id 'id'
    deal_id_origin 'id'
    deal_reference 'ref'
    deal_status 'ACCEPTED'
    direction 'BUY'
    epic 'CS.D.EURUSD.CFD.IP'
    expiry '-'
    guaranteed_stop false
    level 1.1
    limit_level 1.2
    size 5
    status 'OPEN'
    stop_level 1.0
    timestamp '2015-12-15T15:00:00'
  end
end

FactoryBot.define do
  factory :streaming_working_order_update, class: IGMarkets::Streaming::WorkingOrderUpdate do
    account_id 'ACCOUNT'
    channel 'Web'
    currency 'USD'
    deal_id 'DEAL'
    deal_reference 'reference'
    deal_status 'ACCEPTED'
    direction 'BUY'
    epic 'CS.D.EURUSD.CFD.IP'
    expiry '-'
    good_till_date '2015-12-17T14:00:00'
    guaranteed_stop false
    level 1.09
    limit_distance 50
    order_type 'stop'
    size 5
    status 'OPEN'
    stop_distance 50
    time_in_force 'GOOD_TILL_DATE'
    timestamp '2015-12-15T15:00:00.123'
  end
end

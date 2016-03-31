FactoryGirl.define do
  factory :working_order, class: IGMarkets::WorkingOrder do
    created_date '2014/10/20 13:30:03:000'
    currency_code 'USD'
    deal_id 'deal_id'
    direction 'BUY'
    dma false
    epic 'UA.D.AAPL.CASH.IP'
    good_till_date '2015/10/20 10:45:29:000'
    good_till_date_iso '2015-10-30T12:59'
    guaranteed_stop false
    limit_distance 1.0
    order_level 100.0
    order_size 1
    order_type 'LIMIT'
    stop_distance 1.0
    time_in_force 'GOOD_TILL_DATE'

    market { build(:market_overview) }
  end
end

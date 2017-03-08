FactoryGirl.define do
  factory :working_order, class: IGMarkets::WorkingOrder do
    created_date_utc '2014-10-20T13:30:03'
    currency_code 'USD'
    deal_id 'DEAL'
    direction 'BUY'
    dma false
    epic 'UA.D.AAPL.CASH.IP'
    good_till_date '2015/10/30 12:59'
    good_till_date_iso '2015-10-30T12:59'
    guaranteed_stop false
    limit_distance 10
    limited_risk_premium { build :limited_risk_premium }
    order_level 100.0
    order_size 1
    order_type 'LIMIT'
    stop_distance 10
    time_in_force 'GOOD_TILL_DATE'

    market { build :market_overview }
  end
end

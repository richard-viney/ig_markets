FactoryGirl.define do
  factory :streaming_chart_tick_update, class: IGMarkets::Streaming::ChartTickUpdate do
    bid 1.13
    day_high 1.15
    day_low 1.09
    day_net_chg_mid 0.02
    day_open_mid 1.11
    day_perc_chg_mid 1.2
    epic 'CS.D.EURUSD.CFD.IP'
    ltp 1.13
    ltv 10
    ofr 1.132
    ttv 100
    utm '1470731056283'
  end
end

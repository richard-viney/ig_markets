FactoryGirl.define do
  factory :streaming_consolidated_chart_data_update, class: IGMarkets::Streaming::ConsolidatedChartDataUpdate do
    bid_close 1.10883
    bid_high 1.10886
    bid_low 1.10877
    bid_open 1.10878
    cons_tick_count 58
    day_high 1.10967
    day_low 1.10703
    day_net_chg_mid 0.00006
    day_open_mid 1.1088
    day_perc_chg_mid 0.01
    epic 'CS.D.EURUSD.CFD.IP'
    ltv 58.0
    ofr_close 1.10889
    ofr_high 1.10892
    ofr_low 1.10883
    ofr_open 1.10884
    scale :one_minute
    utm '1470731056283'
  end
end

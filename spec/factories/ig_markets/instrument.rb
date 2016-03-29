FactoryGirl.define do
  factory :instrument, class: IGMarkets::Instrument do
    chart_code 'code'
    contract_size '+1'
    controlled_risk_allowed false
    country 'US'
    currencies { [build(:currency)] }
    epic 'UA.D.AAPL.CASH.IP'
    expiry 'expiry'
    expiry_details { build(:instrument_expiry_details) }
    force_open_allowed false
    lot_size 1000.0
    margin_deposit_bands { [build(:instrument_margin_deposit_band)] }
    margin_factor 0.01
    margin_factor_unit 'PERCENTAGE'
    market_id 'market'
    name 'instrument'
    news_code 'news_code'
    one_pip_means ''
    opening_hours { { market_times: [build(:instrument_opening_hours)] } }
    rollover_details { build(:instrument_rollover_details) }
    slippage_factor { build(:instrument_slippage_factor) }
    special_info %w(info_0 info_1)
    sprint_markets_maximum_expiry_time 100.0
    sprint_markets_minimum_expiry_time 10.0
    stops_limits_allowed true
    streaming_prices_available true
    type 'SHARES'
    unit 'SHARES'
    value_of_one_pip 'pip'
  end
end

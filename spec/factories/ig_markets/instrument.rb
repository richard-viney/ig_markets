FactoryGirl.define do
  factory :instrument, class: IGMarkets::Instrument do
    chart_code 'CODE'
    contract_size '+1'
    controlled_risk_allowed false
    country 'US'
    currencies { [build(:instrument_currency)] }
    epic 'ABCDEF'
    expiry '20-DEC-40'
    expiry_details { build :instrument_expiry_details }
    force_open_allowed false
    lot_size 1000.0
    margin_deposit_bands { [build(:instrument_margin_deposit_band)] }
    margin_factor 0.01
    margin_factor_unit 'PERCENTAGE'
    market_id 'MARKET'
    name 'Instrument'
    news_code 'CODE'
    one_pip_means ''
    opening_hours { [build(:instrument_opening_hours)] }
    rollover_details { build :instrument_rollover_details }
    slippage_factor { build :instrument_slippage_factor }
    special_info %w(INFO)
    sprint_markets_maximum_expiry_time 100.0
    sprint_markets_minimum_expiry_time 10.0
    stops_limits_allowed true
    streaming_prices_available true
    type 'SHARES'
    unit 'SHARES'
    value_of_one_pip 'pip'
  end
end
